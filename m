From: Johannes Erdfelt <johannes@erdfelt.com>
Subject: Re: [RFC] tulip VLAN support
Date: Wed, 5 Jan 2005 14:31:47 -0800
Message-ID: <20050105223147.GE18847@sventech.com>
References: <20050105193425.GY18847@sventech.com> <41DC6669.9090407@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DC6669.9090407@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 05, 2005, Jeff Garzik <jgarzik@pobox.com> wrote:
> Johannes Erdfelt wrote:
> >@@ -259,7 +259,7 @@
> > #define RX_RING_SIZE	128 
> > #define MEDIA_MASK     31
> > 
> >-#define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer. 
> >*/
> >+#define PKT_BUF_SZ		1540	/* Size of each temporary Rx buffer. 
> >*/
> 
> This is the reason why the tulip "vlan" patch is continually rejected. 
> You shouldn't need to increase this constant, but rather follow the 
> other "large MTU" driver conversions.

Donald replied to my privately with a number of reasons why similar
patches have been rejected and this one of the same points brought up.

I just copied the 2.4 patch that worked so well for me, but I was
curious about this part of the patch as well.

I asked Donald this, but I guess I'll ask on the list here too. If the
point of PKT_BUF_SZ is to keep a consistent buffer size between drivers
(for performance reasons), why isn't this value defined in a standard
header?

> Donald Becker's tulip.c (on which the kernel tulip is based) supports 
> proper MTU changing: ftp://ftp.scyld.com/pub/network/

The problem isn't changing the MTU, it's that a full ethernet sized
packet along with the 802.1q tagging causes the size of the packet to
grow past the size the driver (and it looks like the chip) will allow.

The driver on Donald's site looks to have the same problem as the driver
in the kernel.

I'm still trying to find some specs on the tulip interface so I can
better understand the chip and the changes necessary to fix this
problem. Anyone have any pointers?

JE
