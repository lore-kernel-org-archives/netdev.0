From: "Anand Kumria" <wildfire@progsoc.org>
Subject: Re: [PATCH] net: Broadcast ARP packets on link local addresses
 (Version2).
Date: Sat, 22 Apr 2006 17:14:44 +0000 (UTC)
Message-ID: <e2doa4$mog$1@sea.gmane.org>
References: <17460.13568.175877.44476@dl2.hq2.avtrex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750725AbWDVROz@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 05 Apr 2006 14:22:08 -0700, David Daney wrote:

> From: David Daney
> 
> Here is a new version of the patch I sent March 31.  For background,
> this is my description from the first patch:
> 
>> When an internet host joins a network where there is no DHCP server,
>> it may auto-allocate an IP address by the method described in RFC
>> 3927.  There are several user space daemons available that implement
>> most of the protocol (zcip, busybox, ...).  The kernel's APR driver
>> should function in the normal manner except that it is required to
>> broadcast all ARP packets that it originates in the link local address
>> space (169.254.0.0/16).  RFC 3927 section 2.5 explains the requirement.
> 
>> The current ARP code is non-compliant because it does not broadcast
>> some ARP packets as required by RFC 3927.
> 
>> This patch to net/ipv4/arp.c checks the source address of all ARP
>> packets and if the fall in 169.254.0.0/16, they are broadcast instead
>> of unicast.
> 
> All of that is still true.
> 
> The changes in this version are that it tests the source IP address
> instead of the destination.  The test now matches the test described
> in the RFC.  Also a small cleanup as suggested by Herbert Xu.
> 
> 
> If the patch is deemed good and correct, great, please apply it.

Could any of the network maintainers comment on this? It'd be nice if
the kernel was even more RFC compliant and, better, did the right
thing too.

Anand
 
> This patch is against 2.6.16.1
> 
> Signed-off-by: David Daney <ddaney@avtrex.com>
> 
> ---
> 
> --- net/ipv4/arp.c.orig	2006-03-31 13:44:50.000000000 -0800
> +++ net/ipv4/arp.c	2006-04-05 13:33:19.000000000 -0700
> @@ -690,6 +690,11 @@ void arp_send(int type, int ptype, u32 d
>  	if (dev->flags&IFF_NOARP)
>  		return;
>  
> +        /* If link local address (169.254.0.0/16) we must broadcast
> +         * the ARP packet.  See RFC 3927 section 2.5 for details. */
> +	if ((src_ip & htonl(0xFFFF0000UL)) == htonl(0xA9FE0000UL))
> +		dest_hw = NULL;
> +
>  	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
>  			 dest_hw, src_hw, target_hw);
>  	if (skb == NULL) {
