From: Glen Gray <glen.gray@lincor.com>
Subject: Re: [PATCH 13/13] r8169: more phy init for the 8168
Date: Thu, 13 Mar 2008 14:20:10 +0000
Message-ID: <328390F7-B41D-4A90-BACA-4746C5E92F1B@lincor.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com> <20071018210224.GN31724@electric-eye.fr.zoreil.com> <471F1067.50403@lincor.com> <20071024221438.GB6189@electric-eye.fr.zoreil.com> <5B10F916-9877-4954-84E7-7F4FE26875C4@lincor.com> <20071031211006.GA12688@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:4500 "EHLO
	scmp07.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752000AbYCMOXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 10:23:09 -0400
In-Reply-To: <20071031211006.GA12688@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Francois,

Spent some time on this yesterday and today, managed to get a Fedora 8  
install up and running on the hardware. This is using the 2.6.24.3  
kernel from Fedora.

Unfortunately it's still got exactly the same problem, specifically,  
the device comes up and doesn't see any SAP announcements. It's  
getting it's IP address via DHCP.

cat /proc/net/igmp also shows it as V3. If I force it to version 2 it  
still doesn't seem to detect anything.

You suggested the patch below back in October and I didn't get any  
time to work on it. I've just checked the source for the Fedora  
2.6.24.3 kernel and it doesn't have the blow in there, so I'm going to  
patch this against the kernel and see if it helps in anyway.

If you've any further suggestions then please pass them on.

Appropriate data from dmesg........
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
eth0: RTL8169sc/8110sc at 0xdc868000, 00:05:6b:40:2c:be, XID 18000000  
IRQ 18
r8169: eth0: link up

Kind Regards,
--
Glen Gray <glen.gray@lincor.com>         Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

On 31 Oct 2007, at 21:10, Francois Romieu wrote:

> Glen Gray <glen.gray@lincor.com> :
> [...]
>> However, we do have a few hundred units out in the field now that
>> we'll need to support going forward. So I'm keeping an eye on this
>> issue's progress.
>
> Can you try 2.6.13 + the patch below if you have some time left ?
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index b94fa7e..1191802 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1367,8 +1367,10 @@ static void rtl8169_phy_timer(unsigned long  
> __opaque)
> 		goto out_mod_timer;
> 	}
>
> -	if (tp->link_ok(ioaddr))
> +	if (tp->link_ok(ioaddr)) {
> +		dev->set_multicast_list(dev);
> 		goto out_unlock;
> +	}
>
> 	if (netif_msg_link(tp))
> 		printk(KERN_WARNING "%s: PHY reset until link up\n", dev->name);
> -- 
> Ueimor

