From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: R: Re: mtu issue with ipsec tunnel and netfilter snat
Date: Thu, 10 Jan 2013 18:57:04 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301101853420.25111@nerf07.vanv.qr>
References: <8364295.258481357836417891.JavaMail.defaultUser@defaultHost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "pupilla@libero.it" <pupilla@libero.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:58897 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753530Ab3AJR5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 12:57:07 -0500
In-Reply-To: <8364295.258481357836417891.JavaMail.defaultUser@defaultHost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2013-01-10 17:46, pupilla@libero.it wrote:

>jengelh@inai.de wrote:
>>>
>>>But why linux_gw_snat is not sending icmp need to frag packets to
>>>10.148.12.23?
>>
>>Perhaps because ICMP was blocked erroneously?
>
>well, I don't see the icmp packets because tcpdump 'see' only the 
>incoming ipsec clear packets. Is there a way to see the outgoing clear 
>ipsec packets with tcpdump?

Not with AF_PACKET sockets (tcpdump uses such), but you could with 
iptables -j LOG, NFLOG and TRACE they can be made visible. If you need 
the full packet, you can either patch up LOG to call the kernel hexdump 
functions, or use NFLOG - I think - to deliver it to any userspace 
program to do further processing. If all else fails, there is also 
NFQUEUE with which the packet can also be copied to userspace.
