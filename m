From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 21:34:53 +0200
Message-ID: <20170518193453.GB13759@lunn.ch>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
 <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com>
 <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This most certainly works fine in the simple case where you have one PHY
> > hanging off the MDIO bus, now what happens if you have several?
> >
> > Presumably, the first PHY that returns EPROBE_DEFER will make the entire
> > bus registration return EPROB_DEFER as well, and so on, and so forth,
> > but I am not sure if we will be properly unwinding the successful
> > registration of PHYs that either don't have an interrupt, or did not
> > return EPROBE_DEFER.
> >
> > It should be possible to mimic this behavior by using the fixed PHY, and
> > possibly the dsa_loop.c driver which would create 4 ports, expecting 4
> > fixed PHYs to be present.
> 
> mdiobus_unregister(), called from of_mdiobus_register() on failure,
> should do the unwinding, right?
> 
> And when the driver is reprobed, all PHYs are reprobed, until they all
> succeed.

That is the theory. I looked at that while reviewing the patch. But
this has probably not been tested in anger. It would be good to test
this properly, with not just the first PHY returning -EPROBE_DEFER, to
really test the unwind.

    Andrew
