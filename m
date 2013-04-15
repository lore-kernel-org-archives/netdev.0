From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: No longer able to add iptunnel interface to bridge?
Date: Mon, 15 Apr 2013 11:12:13 -0700
Message-ID: <20130415111213.62c4d117@samsung-9>
References: <Pine.LNX.4.61.1304151757340.20041@envy.nxs.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tomas Agartz <tlund@nxs.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:52766 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab3DOSMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:12:20 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so2179733dan.10
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 11:12:20 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.61.1304151757340.20041@envy.nxs.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Apr 2013 18:14:32 +0200 (CEST)
Tomas Agartz <tlund@nxs.se> wrote:

> After rebooting my router/firewall (Debian Wheezy with debian 3.2.41-2 
> kernel), I am no longer able to add an iptunnel to a bridge interface.
> 
> The iptunnel is configured like this:
> 
> iptunnel add TUNNEL mode ipip remote x.x.x.x local y.y.y.y ttl 32
> ifconfig TUNNEL z.z.z.z netmask 255.255.255.254 up
> 
> and this is what strace shows when I try to do "brctl addif test TUNNEL":
> 
> ioctl(3, SIOCBRADDIF, 0x7fffafba64c0)   = -1 EINVAL (Invalid argument)
> ioctl(3, SIOCDEVPRIVATE, 0x7fffafba64c0) = -1 EINVAL (Invalid argument)
> 
> I have no idea if I might have changed something in userspace by misstake, 
> or if there has been a change in the kernel since last reboot. The same 
> machine has a different bridge with an L2TPv3 tunnel added, this works 
> fine.
> 
> I understand that the info here is not much to go on, but I am unsure what 
> else to attach. Plese ask for further info and I shall provide it!
> 
> Best regards,
> Tomas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

You created a network level (L3) tunnel, which starts with IP header.
Bridging requires an Ethernet like (L2) tunnel, where packets start with Ethernet header.
