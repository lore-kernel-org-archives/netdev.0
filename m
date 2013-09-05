From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Thu, 5 Sep 2013 09:28:08 +0200
Message-ID: <20130905092808.617da416@skate>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130904163245.GI20552@1wt.eu>
	<CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
	<20130905051223.GB26000@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ethan Tuttle <ethan@ethantuttle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Peter Sanford <psanford@nearbuy.io>,
	=?UTF-8?B?Q2jDqW55?= Yves-Gael <yves@cheny.fr>,
	Ryan Press <ryan@presslab.us>,
	Simon Guinot <simon.guinot@sequanux.org>, vdonnefort@lacie.com,
	stable@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130905051223.GB26000@1wt.eu>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, 5 Sep 2013 07:12:23 +0200, Willy Tarreau wrote:

> > This is on 3.11 plus Thomas' patch, which includes the previous fix to
> > "read MAC address from hardware when available".  Perhaps that fix
> > isn't working with the phylib?
> 
> No this is unrelated. The MAC isn't configured by the boot loader when
> the NIC is not used. U-boot only passes it as a non-standard ATAG. I
> have some patches to reinject the non-standard atags into the device
> tree if you absolutely need this, but they're not suited for mainline
> inclusion from what I understood last time I proposed them (they use
> a marvell-specific atag header).

I indeed submitted a revised/improved version of your patches some time
ago, but they were rejected. See
http://lists.infradead.org/pipermail/linux-arm-kernel/2013-June/173201.html.
Since this has been rejected, the available options are:

 (1) Use a DT-capable bootloader that will properly set the MAC
     addresses in the DT. Such DT capable bootloaders will soon be made
     available by Marvell, but I am really unsure Globalscale will
     provide an update for the Mirabox bootloader, rebased on the new
     Marvell bootloader that will be DT capable.

     As an alternative, we (mainly Sebastian Hesselbarth and myself)
     have started adding Armada 370/XP support in the Barebox
     bootloader. We can already start Barebox on the Mirabox, but for
     now it's quite useless since only the serial port is supported,
     there is still no support for the network, SD card, USB or NAND.
     This will probably come over time, but it's not going to happen
     overnight.

 (2) Use the "impedance matcher" code written by Daniel Mack and
     extended by Jason Cooper, available at
     https://github.com/zonque/pxa-impedance-matcher. Essentially, it
     inserts a small binary between the installed bootloader and the
     kernel, that for example allows to choose a particular DTB amongst
     several, depending on the board that is detected. I believe it
     could probably be extended to cover other use cases such as
     modifying the DTB to add the MAC addresses where appropriate. I've
     added Jason Cooper in the Cc list if he wants to comment on that.

 (3) Continue to manually apply the patches from Willy that add support
     for the Marvell-specific ATAGs.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
