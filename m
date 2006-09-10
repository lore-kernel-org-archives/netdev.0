From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168, 2.6.17 et r8169.c
Date: Sun, 10 Sep 2006 23:42:54 +0200
Message-ID: <20060910214254.GA22831@electric-eye.fr.zoreil.com>
References: <200609091201.03603.corentincj@iksaif.net> <20060909112414.GA2877@electric-eye.fr.zoreil.com> <200609091451.14579.corentincj@iksaif.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48273 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932094AbWIJVoi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 17:44:38 -0400
To: Corentin CHARY <corentincj@iksaif.net>
Content-Disposition: inline
In-Reply-To: <200609091451.14579.corentincj@iksaif.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corentin CHARY <corentincj@iksaif.net> :
[no need to quote the original part in french]
> I have a Asus Laptop A6JC, and a r8168 network card. r1000 driver from realtek 
> works, but I want to use r8169.c.
> I first tried with 
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.17-rc6/r8169/ patchs, but it 
> doesn't Work (eth0 is here, I can use ifconfig and route, but ping or dhcpcd 
> doesn't work) 

If you still have it at hand, turn NET_IP_ALIGN into NET_IP_ALIGN + 6
and it should work (at least it has been reported to by Boris Zhmurov).

[...]
> Now I tried with http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc5/r8169/ 
> I changed :
> line 1751
> - request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED, dev->name, dev);
> + request_irq(dev->irq, rtl8169_interrupt, SA_SHIRQ, dev->name, dev);
> line 2224
> - u32 mss = skb_shinfo(skb)->gso_size;
> + u32 mss = skb_shinfo(skb)->tso_size;
> to get it compile on 2.6.17
> 
> I can load the module, eth0 is here, I can play with ifconfig. But i can't 
> ping other machines on my network. dhcpd doesn't work too.
> 
> dmesg output :
[...]

Full story please, no cut.

[...]
> I tried mii-tool (and mii-diag) but I get that :
> SCIOCGMIIPHY on eth0 failed: Operation not supported

Huh ?

Are you really sure that you have applied the 11 patches
and built the right file ?

-- 
Ueimor
