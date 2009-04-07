From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 7 Apr 2009 07:16:25 -0400
Message-ID: <200904070716.25846.rgetz@blackfin.uclinux.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <1239044483.14392.55.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Chris Peterson" <cpeterso@cpeterso.com>
To: "Matt Mackall" <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755378AbZDGLO0@vger.kernel.org>
In-Reply-To: <1239044483.14392.55.camel@calx>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 6 Apr 2009 15:01, Matt Mackall pondered:
> On Mon, 2009-04-06 at 14:30 -0400, Robin Getz wrote:
> > We have lots of embedded headless systems (no keyboard/mouse, no
> > soundcard, no video) systems with *no* sources of entropy - and
> > people using SSL. 
> 
> I'd rather add a random_sample_network call somewhere reasonably central
> in the network stack. Then we can use the knowledge that the sample is
> network-connected in the random core to decide how to measure its
> entropy. The trouble with IRQF_SAMPLE_RANDOM is that many of its users
> are technically bogus as entropy sources in the current model.

OK - that makes more sense.

Does that mean we also shouldn't be using IRQF_SAMPLE_RANDOM on interrupt 
sources in subsystems which already have add_xxx_randomness() in them? (block 
devices, and input devices?)

block/blk-core.c -> blk_end_io() -> add_disk_randomness()
drivers/input/input.c -> input_event() -> add_input_randomness()

 drivers/block/xen-blkfront.c, line 639

 drivers/input/touchscreen/wm97xx-core.c, line 374
 drivers/input/keyboard/gpio_keys.c, line 145
 drivers/input/keyboard/bf54x-keys.c, line 255
 drivers/input/serio/hp_sdc.c, line 881

> I'm eventually going to move the RNG away from the strict theoretical
> entropy accounting model to a more pragmatic one which will be much
> happier with iffy entropy sources, but that's a ways off.

Looking forward to it.
