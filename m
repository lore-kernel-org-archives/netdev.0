From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: lan9303: Fixed MDIO interface
Date: Fri, 28 Jul 2017 15:36:37 +0200
Message-ID: <20170728133637.GB32230@lunn.ch>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-2-privat@egil-hjelmeland.no>
 <20170726165550.GN12049@lunn.ch>
 <4e36827f-fdcc-d55a-3559-e080883c715c@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4e36827f-fdcc-d55a-3559-e080883c715c@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 01:08:25PM +0200, Egil Hjelmeland wrote:
> On 26. juli 2017 18:55, Andrew Lunn wrote:
> >On Tue, Jul 25, 2017 at 06:15:44PM +0200, Egil Hjelmeland wrote:
> >It is better to use mdiobus_read/write or if you are nesting mdio
> >busses, mdiobus_read_nested/mdiobus_write_nested. Please test this
> >code with lockdep enabled.
> >
> 
> I have CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_MUTEXES. Should I enable
> more?

Hi Egil

Enable CONFIG_LOCKDEP and CONFIG_PROVE_LOCKING.

Any lockdep splat you get while accessing the mdio bus at this point
are probably false positives, since it is a different mutex. Using the
_nested() version should avoid these false positives. But you might
find other places your locking is not right.

	Andrew
