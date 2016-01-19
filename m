From: David Miller <davem@davemloft.net>
Subject: Re: question about samsung/sxgbe/sxgbe_xpcs.c
Date: Tue, 19 Jan 2016 14:36:28 -0500 (EST)
Message-ID: <20160119.143628.432983847877790677.davem@davemloft.net>
References: <alpine.DEB.2.10.1601191723250.2531@hadrien>
	<CAKocOOOFrEFLL0MWnn_bhBby8GeVH82A2wtaL9Tg9QTJC2Wprw@mail.gmail.com>
	<alpine.DEB.2.10.1601191918470.2531@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shuahkhan@gmail.com, bh74.an@samsung.com, ks.giri@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shuahkh@osg.samsung.com
To: julia.lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1601191918470.2531@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 19 Jan 2016 19:54:20 +0100 (CET)

> On Tue, 19 Jan 2016, Shuah Khan wrote:
> 
>> 2016-01-19 9:26 GMT-07:00 Julia Lawall <julia.lawall@lip6.fr>:
>> > Hello,
>> >
>> > I was windering what is the purpose of the file
>> > drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
>>
>> From git log and comments, it appears this driver is for
>> Samsung SoCs.
>>
>> >
>> > I can't find anything that refers to it, and if I remove it from the
>> > makefile:
>> >
>> > @@ -1,4 +1,4 @@
>> >  obj-$(CONFIG_SXGBE_ETH) += samsung-sxgbe.o
>> >  samsung-sxgbe-objs:= sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
>> >                 sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
>> > -               sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
>> > +               sxgbe_ethtool.o $(samsung-sxgbe-y)
>> >
>> > and then make clean and recompile, I see no bad effect.
>> >
>>
>> What is the motivation for the experiment to remove it?
>> This file probably gets used only on Samsung SoCs.
> 
> I just wondered.  I was looking at dependencies between networking files.
> This one stands out because nothing is dependenton it, even the files it
> is compiled with, and it doesn't contain the usual functions,
> register_netdev, etc.

Even with that explanation, this is a bogus situation.

There are no in-tree callers of this code.  It should be removed until there
are in-tree users.

Nobody can figure out if the interface for this is done properly without seeing
the call sites and how they work.  It is therefore impossible to review this
code and judge it's design.

If someone doesn't send me a removal patch, I will remove this code myself.
