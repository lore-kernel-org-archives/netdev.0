From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 2/2] pcnet32: fix BNC/AUI port on AM79C970A
Date: Tue, 14 Feb 2017 21:54:58 +0100
Message-ID: <201702142154.59035.linux@rainbow-software.org>
References: <1487025947-28867-1-git-send-email-linux@rainbow-software.org> <1487025947-28867-2-git-send-email-linux@rainbow-software.org> <20170214.142856.670670406050328036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214.142856.670670406050328036.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 February 2017 20:28:56 David Miller wrote:
> From: Ondrej Zary <linux@rainbow-software.org>
> Date: Mon, 13 Feb 2017 23:45:47 +0100
>
> > Even though the port autoselection is enabled by default on AM79C970A,
> > BNC/AUI port does not work because the link is always reported to be
> > down. The link state reported by the chip belongs only to the TP port
> > but the driver uses it regardless of the port used. The chip can't
> > detect BNC/AUI link state.
> >
> > Disable port autoselection and use TP port by default to keep current
> > behavior (link detection works on TP port, BNC/AUI port does not work).
> >
> > Implement ethtool autoneg, port and duplex configuration to allow
> > using the BNC/AUI port.
> >
> > Report the TP link state only if the TP port is selected. When the
> > port autoselection is enabled or AUI port is selected, report the link
> > as always up.
> >
> > Move pcnet32_suspend() and pcnet32_clr_suspend() functions to avoid
> > forward declarations.
> >
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
>
> Also applied to net-next, thanks.
>
> Are you really sure the is no way to discover the BNC/AUI link state
> from the hardware?

Yes, searched through the datasheet: http://support.amd.com/TechDocs/19436.pdf

Even the TP link detection seems a bit wrong - the driver reads link LED state 
(there's no other way) but does not ensure that the LED is really programmed 
to represent link state. But I'm better not touching that - it works for me 
and probably for other people too.

Thought at first that the card (Microdyne NE5500+) is faulty as BNC didn't 
work in Linux and also in Windows XP. But then I tested Windows 98 and it 
worked fine (the driver uses port autoselect).

Turned out that the Windows XP driver is broken. It uses manual port 
selection - works in TP mode (including link state detection) but does not 
work in BNC/AUI mode.

-- 
Ondrej Zary
