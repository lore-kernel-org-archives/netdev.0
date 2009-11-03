From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Tue, 3 Nov 2009 23:34:40 +0100
Message-ID: <200911032334.40547.bzolnier@gmail.com>
References: <200911031951.05235.bzolnier@gmail.com> <200911032244.11946.bzolnier@gmail.com> <200911032301.32907.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754624AbZKCWfv@vger.kernel.org>
In-Reply-To: <200911032301.32907.IvDoorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 November 2009 23:01:32 Ivo van Doorn wrote:
> > > > The following patch series (against wireless-next) addresses issues raised
> > > > during code review and subsequently rejected by rt2x00/wireless/networking
> > > > maintainers.
> > > 
> > > Really stop reading only the half of emails, try reading it entirely (or at least don't
> > > stop at the second word in a sentence). It really starts the bug me to repeat
> > > myself over and over again because you refuse to read.
> > > 
> > > Your comments during code review were ACCEPTED with the only remark that
> > > it shouldn't be done right here and now.
> > 
> > Please stop this bullshit.  We have some standards for the upstream code
> > and by being maintainer you have to live up to this standards and make sure
> > that they are respected instead of watering them down yourself..
> > 
> > You were not interested even in fixing the headers duplication (it turned
> > out debugging scripts needed only 25 lines of code to be able to work with
> > fixed headers -- 25 LOC in bash scripts used only for debugging instead
> > of 1800 LOC of kernel code).
> 
> Yeah I know that. But like I said, I still needed to get around to do that,
> and I am very happy you were interested in fixing it.

Lets make one thing clear: YOU SHOULD BE THE ONE FIXING IT.

I'm not in slightest interested in wasting my time on such
things and educating some maintainers about basics.

[ Code duplication is bad, mmm'okay?  Just say no, mmm'okay? ]

> > Also: I've mostly heard that I can fix the code myself.  Which I did.
> 
> And thats good.
> 
> > > > The rewrite was quite conservative and there is still a room for improvement
> > > > but it should serve as a good starting base for all future work on rt2800
> > > > drivers, and there is a lot to do there (both drivers are still practically
> > > > non-functional).
> > > 
> > > Hence the reason I can use my rt2800usb device as long as I don't connect to
> > > a 11n AP. But since everybody in the world has 11n devices, the rt2800usb device
> > > is not capable of doing anything...
> > 
> > I use 11bg AP but mine rt2800usb device is RT3070 (which is quite popular
> > nowadays) and it simply doesn't even work with rt2800usb currently.
> 
> Mine devices are plain rt2870 chips.
> 
> > > > Comments and patches are welcomed.
> > > > 
> > > > 
> > > > The following changes since commit fa867e7355a1bdcd9bf7d55ebe9296f5b9c4028a:
> > > >   Juuso Oikarinen (1):
> > > >         wl1271: Generalize command response reading
> > > > 
> > > > are available in the git repository at:
> > > > 
> > > >   git://git.kernel.org/pub/scm/linux/kernel/git/bart/misc.git rt2800
> > > > 
> > > > Bartlomiej Zolnierkiewicz (40):
> > > >       rt2800usb: fix rt2800usb_rfcsr_read()
> > > >       rt2800pci: fix crypto in TX frame
> > > >       rt2800pci: fix comment about register access
> > > >       rt2800pci: fix comment about IV/EIV fields
> > > >       rt2x00: fix rt2x00usb_register_read() comment
> > > >       rt2800usb: use rt2x00usb_register_multiwrite() to set key entries
> > > [.. snip..]
> > > >       rt2800usb: fix comments in rt2800usb.h
> > > >       rt2800usb: add RXINFO_DESC_SIZE definition
> > > [..snip..]
> > > >       rt2800: fix comments in rt2800.h
> > > [..snip..]
> > > >       rt2x00: remove needless ifdefs from rt2x00leds.h
> > > 
> > > These 10 patches look sane enough. Please send them as patch series
> > > to linux-wireless.
> 
> > I'll re-post later whole patch series to linux-wireless to ease the review.
> 
> Make them 2 series, the above can be the real [PATCH] (which I will ack directly),
> and the others can be RFC's which can be reviewed/discussed further.

Please at least read all patches before even starting making such comments:

i.e. "rt2800: fix comments in rt2800.h" depends on
"rt2800: fix duplication in header files"

and redoing it would be plain waste of time.

Besides for now I'm more interested in working on improving drivers further
than making artificial patch splits.

> > > >       rt2x00: add support for different chipset interfaces
> > > 
> > > Not needed, you can determine exactly what chipset you have
> > > by looking at the other fields. So extending the structure to
> > > repeat the same information isn't needed.
> > 
> > It is a better to have a single field always indicating this since:
> > - combining information from other fields is complex and error-prone
> > - the situation may change in the future
> > 
> > However I would love to be proven wrong with the patch.
> 
> Well something that looks like this (as function in rt2800lib.h)
> 
> static inline is_rt2800pci(__chip)
> {
> 	return
> 		(__chip->rt & 0xFF00) == 0x0600 ||
> 		(__chip->rt & 0xFF00) == 0x0700 ||
> 		__chip->rt == 0x2880 ||
> 		__chip->rt == RT3052;
> }
> 
> You might even go a bit shorter by checking for USB instead:
> 
> static inline is_rt2800usb(__chip)
> {
> 	return __chip->rt == RT2870
> }

Which can turn into maintenance nightmare as might need update
each time new chipset version is added and is error-prone.

Setting chipset interface from the driver itself is much more
maintainer friendly.

> In rt2800lib you already know __chip->rt is part of
> the rt2800 family, the is_rt2800usb() (or whatever name
> you are going to give that function) is sufficient to know
> if you are using PCI or USB.
> 
> And when that is not good enough, then please change the
> field to only indicate PCI or USB. That way the field could be
> used for other things in the future.

Please explain what do you mean by that.  The field in question is enum:

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: [PATCH] rt2x00: add support for different chipset interfaces

[ Impact: rt2x00 infrastructure enhancement ]

Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
---
 drivers/net/wireless/rt2x00/rt2x00.h |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

Index: b/drivers/net/wireless/rt2x00/rt2x00.h
===================================================================
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -144,6 +144,11 @@ struct avg_val {
 	int avg_weight;
 };
 
+enum rt2x00_chip_intf {
+	RT2X00_CHIP_INTF_PCI,
+	RT2X00_CHIP_INTF_USB,
+};
+
 /*
  * Chipset identification
  * The chipset on the device is composed of a RT and RF chip.
@@ -169,6 +174,8 @@ struct rt2x00_chip {
 
 	u16 rf;
 	u32 rev;
+
+	enum rt2x00_chip_intf intf;
 };
 
 /*
@@ -937,6 +944,18 @@ static inline bool rt2x00_check_rev(cons
 	return ((chipset->rev & mask) == rev);
 }
 
+static inline void rt2x00_set_chip_intf(struct rt2x00_dev *rt2x00dev,
+					enum rt2x00_chip_intf intf)
+{
+	rt2x00dev->chip.intf = intf;
+}
+
+static inline bool rt2x00_intf(const struct rt2x00_chip *chipset,
+			       enum rt2x00_chip_intf intf)
+{
+	return (chipset->intf == intf);
+}
+
 /**
  * rt2x00queue_map_txskb - Map a skb into DMA for TX purposes.
  * @rt2x00dev: Pointer to &struct rt2x00_dev.


-- 
Bartlomiej Zolnierkiewicz
