From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Tue, 4 Nov 2008 17:04:22 -0700
Message-ID: <200811041604.22947.david-b@pacbell.net>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <fa686aa40811040824x52dab7fel9f76567cb6d49c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <fa686aa40811040824x52dab7fel9f76567cb6d49c8@mail.gmail.com>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 November 2008, Grant Likely wrote:
> At this point, instead of #ifdeffing the function signature, I would
> much rather see this generalized as something like
> 'mdio_gpio_setup()'. =A0Then move the OF and non-OF specific bits int=
o
> two new functions; mdio_ofgpio_probe() and mdio_gpio_probe(). =A0The =
two
> new functions should be placed with the appropriate bus binding in th=
e
> #ifdef/#else block at the bottom of the file.

Or if possible something that creates a single #ifdef that
ensures dead code elimination will remove the "other" branch,
but ensures all platforms will build both versions:

    #ifdef OF
    #define using_of	true
    #else
    #define using_of	false
    #endif

    ...

    static int __init mdio_gpio_init(void)
    {
	if (using_of)
		return register mdio_ofgpio driver;
	else
		return register mdio_gpio driver;
    }
    subsys_initcall(mdio_gpio_init);

    ...

That's generally the preferred way to handle #ifdeffery.
But I could imagine OF isn't (yet?) set up to handle it.

- Dave
