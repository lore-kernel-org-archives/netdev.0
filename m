From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Add rtl8187 wireless driver
Date: Mon, 07 May 2007 16:25:18 -0700 (PDT)
Message-ID: <20070507.162518.35013789.davem@davemloft.net>
References: <200705071022.11711.flamingice@sourmilk.net>
	<463F44E6.5030705@garzik.org>
	<200705071917.25414.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	andrea.merello@gmail.com
To: flamingice@sourmilk.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43415
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967111AbXEGXZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 19:25:15 -0400
In-Reply-To: <200705071917.25414.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>
Date: Mon, 7 May 2007 19:17:20 -0400

> On Monday 07 May 2007 11:25, Jeff Garzik wrote:
> > I am a bit skeptical that multiple files are needed.  It seems like
> > drivers/net/wireless/rtl818x.c would be a better path, a la tg3.c.
> >
> The radio tuning stuff could be stuffed into rtl8187_dev.c, but I like to keep 
> it separate since rtl8187_rtl8225.c tends to contain all the radio tuning 
> black magic that no one really understands except for the engineers at 
> Realtek, whereas rtl8187_dev.c is mostly straightforward. rtl8187 can also 
> (in theory) use another radio chip (rtl8255). The two headers - rtl818x.h and 
> rtl8187.h cannot be merged because the definitions in rtl818x.h are shared 
> between the usb and pci drivers.
> 
> I rather not combine any files, though I don't mind collapsing the driver 
> another level. However, I think other driver authors much prefer having their 
> own directory, and I'd like to keep the drivers consistently in their own 
> directory or all together in drivers/net/wireless.

I certainly don't like it, sometimes I won't look at how e1000 (for
example) does things when researching a patch or some aspect of the
networking simply because I have to type in and TAB complete another
directory to get into where the driver's source file live.

I know this sounds trite, but when merging and researching up to 450
patches at a time like I have to, this stuff starts to matter.

Please put things as high in the directory hierachy as possible and
when you can put the entire driver into a single source file do so.

The only significant argument you present is the code sharing one for
the radio stuff, but that isn't realized yet and you can certainly
split the code out once you make that sharing a reality.
