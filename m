From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch] Re: Gigabit Kconfig problems with yesterday's update
Date: Sun, 30 May 2004 13:06:53 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.58.0405301302020.1632@ppc970.osdl.org>
References: <40B8A37D.1090802@myrealbox.com> <20040530134544.GE13111@fs.tum.de>
 <20040530143734.GA24627@dth.net> <20040530094120.61b22d2e.rddunlap@osdl.org>
 <40BA1F25.4080402@pobox.com> <20040530193706.GG13111@fs.tum.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	"Randy.Dunlap" <rddunlap@osdl.org>, Danny ter Haar <dth@dth.net>,
	wa1ter@myrealbox.com, dth@ncc1701.cistron.net,
	Netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264348AbUE3UHW@vger.kernel.org>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20040530193706.GG13111@fs.tum.de>
List-Id: netdev.vger.kernel.org



On Sun, 30 May 2004, Adrian Bunk wrote:
> 
> 
> This is not sufficient since it's still under the
> "Ethernet (10 or 100Mbit)" menu.
> 
> What about the patch below?
>
>  config NET_ETHERNET
> -	bool "Ethernet (10 or 100Mbit)"
> +	bool "Ethernet (10/100/1000/10000 Mbit)"

Ok, this part is obviously sane.

However:

> +menu "Ethernet (10/100 Mbit)"
> +	depends on NET_ETHERNET
> +
>  
>  menu "Gigabit Ethernet (1000/10000 Mbit)"
> -	depends on NETDEVICES
> +	depends on NET_ETHERNET

is it really sane these days to split out gigabit from the "regular" 
ethernets? gigabit ethernet is getting quite a bit more common than it 
used to be, and a lot of the gigabit devices are just "standard ethernet" 
as far as the user is concerned, and in fact they are often _used_ in just 
regular 10/100Mbps setups.

In other words: it's quite understandable if somebody doesn't even
_realize_ that his chip supports gigabit speeds these days.

So wouldn't the right fix be to just remove the distinction between 
"regular" and "gigabit" ethernet, and put them all in the same menu?

If the menu then grows really big, maybe we can split it according to some 
_saner_ split. Not that I can see off-hand what that would be, but..

		Linus
