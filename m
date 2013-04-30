From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v6 4/5] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 11:59:58 +0800
Message-ID: <1367294398.3216.8.camel@cr0>
References: <1366782874-18700-1-git-send-email-amwang@redhat.com>
	 <1366782874-18700-5-git-send-email-amwang@redhat.com>
	 <20130429.115214.930181179286504457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab3D3EAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 00:00:22 -0400
In-Reply-To: <20130429.115214.930181179286504457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 11:52 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 24 Apr 2013 13:54:33 +0800
> 
> > +	rc = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
> > +	if (rc < 0) {
> > +		pr_debug("UDP socket create failed\n");
> > +		return rc;
> > +	}
> 
> You have to fall back to creating and using an ipv4 socket if making
> the ipv6 one fails.
> 
> IPV6 being enabled does not mean it is guaranteed the one can
> successfully create ipv6 sockets.
> 
> You also must handle /proc/sys/net/ipv6/conf/${DEV}/disable_ipv6
> correctly as far as this stuff goes as well.
> 

Right, we should detect the run-time IPv6 support too.
