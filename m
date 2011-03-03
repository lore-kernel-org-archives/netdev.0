From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [BUG] VPN broken in net-next
Date: Thu, 3 Mar 2011 15:09:22 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
References: <20110302.164333.116393112.davem@davemloft.net> <20110302164637.6651b34f@nehalam> <20110302.165009.200353108.davem@davemloft.net> <20110302.165421.258093056.davem@davemloft.net> <alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53171 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758267Ab1CCNFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:05:06 -0500
In-Reply-To: <alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 3 Mar 2011, Julian Anastasov wrote:

> 	May be the problem is in inet_hash_insert(), it should
> hash ifa_local, not ifa_address. May be they are equal for

 	... and of course the new __ip_dev_find should use
ifa_local too.

> the common case but not for peer addresses. In devinet_ioctl()
> we can see they are equal initially:
>
> ifa->ifa_address = ifa->ifa_local = sin->sin_addr.s_addr;
>
> 	but later SIOCSIFDSTADDR can change ifa_address which
> is destination address from the same prefix:
>
> ifa->ifa_address = sin->sin_addr.s_addr;

 	While checking for ifa_address usage I see other
two places that look suspicious:

- inet_gifconf() exposes address from ifa_local but then
devinet_ioctl() matches by ifa_address in the
'if (tryaddrmatch)' block. I think, we should use ifa_local.

- IN_DEV_ARP_NOTIFY: announces ifa_address instead of ifa_local.

Regards

--
Julian Anastasov <ja@ssi.bg>
