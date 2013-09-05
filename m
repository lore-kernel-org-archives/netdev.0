From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure adjust_link() works
Date: Thu, 5 Sep 2013 09:44:26 +0200
Message-ID: <20130905074426.GD26000@1wt.eu>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com> <20130904163245.GI20552@1wt.eu> <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com> <20130905051223.GB26000@1wt.eu> <20130905092808.617da416@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ethan Tuttle <ethan@ethantuttle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Peter Sanford <psanford@nearbuy.io>,
	=?iso-8859-1?Q?Ch=E9ny?= Yves-Gael <yves@cheny.fr>,
	Ryan Press <ryan@presslab.us>,
	Simon Guinot <simon.guinot@sequanux.org>, vdonnefort@lacie.com,
	stable@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130905092808.617da416@skate>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,

On Thu, Sep 05, 2013 at 09:28:08AM +0200, Thomas Petazzoni wrote:
> I indeed submitted a revised/improved version of your patches some time
> ago, but they were rejected. See
> http://lists.infradead.org/pipermail/linux-arm-kernel/2013-June/173201.html.

Thanks for the link, that's indeed what I was referring to. Well, at least
the most boring part that constantly needed to be rebased was the DT patch.
Now it's much easier to keep the small remaining patches in one's local tree.

> Since this has been rejected, the available options are:
> 
>  (1) Use a DT-capable bootloader that will properly set the MAC
>      addresses in the DT. Such DT capable bootloaders will soon be made
>      available by Marvell, but I am really unsure Globalscale will
>      provide an update for the Mirabox bootloader, rebased on the new
>      Marvell bootloader that will be DT capable.

One simpler solution for them could be to slightly modify the boot loader
so that it sets the MAC address on the two ethernet controllers prior to
boot. Then your code which checks if a MAC is already set will simply
work.

>      As an alternative, we (mainly Sebastian Hesselbarth and myself)
>      have started adding Armada 370/XP support in the Barebox
>      bootloader. We can already start Barebox on the Mirabox, but for
>      now it's quite useless since only the serial port is supported,
>      there is still no support for the network, SD card, USB or NAND.
>      This will probably come over time, but it's not going to happen
>      overnight.

And we must keep in mind that people are generally scared by boot loader
upgrades, especially when it's for a different one. At least on this
platform now we have a solution to reflash even after complete failures
so this is less of a problem.

>  (2) Use the "impedance matcher" code written by Daniel Mack and
>      extended by Jason Cooper, available at
>      https://github.com/zonque/pxa-impedance-matcher. Essentially, it
>      inserts a small binary between the installed bootloader and the
>      kernel, that for example allows to choose a particular DTB amongst
>      several, depending on the board that is detected. I believe it
>      could probably be extended to cover other use cases such as
>      modifying the DTB to add the MAC addresses where appropriate. I've
>      added Jason Cooper in the Cc list if he wants to comment on that.

Could be a nice solution as well, indeed.

A last one would be to have the mvneta module accept an array of addresses
as a module parameter. This way it would just require a minor change in the
kernel's cmdline to pass the MAC addresses. I remember seeing this in the
past, I don't remember the platform (maybe the NSLU2 but I could be wrong).

Cheers,
Willy
