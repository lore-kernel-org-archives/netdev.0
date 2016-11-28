From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Mon, 28 Nov 2016 20:23:06 +0100
Message-ID: <20161128192306.GA11474@microsemi.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
 <20161128141410.GF4379@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0058.outbound.protection.outlook.com ([104.47.42.58]:22656
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751824AbcK1TXk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 14:23:40 -0500
Content-Disposition: inline
In-Reply-To: <20161128141410.GF4379@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew and Florian,

On 28/11/16 15:14, Andrew Lunn wrote:
> On Mon, Nov 28, 2016 at 02:24:30PM +0100, Allan W. Nielsen wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > 3 types of PHY loopback are supported.
> > i.e. Near-End Loopback, Far-End Loopback and External Loopback.
> Is this integrated with ethtool --test? You only want the PHY to go
> into loopback mode when running ethtool --test external_lb or maybe
> ethtool --test offline.
There are other use-cases for enabling PHY loopback:

1) If the PHY is connected to a switch then a loop-port is sometime
   used to "force/enable" one or more extra pass through the switch
   core. This "hack" can sometime be used to achieve new functionality
   with existing silicon.

2) Existing user-space application may expect to be able to do the
   testing on its own (generate/validate the test traffic).

> What i think should happen is that this tunable sets the mode the
> PHY will go into when loopback is enabled. It does not however
> enable loopback.
That does not make a lot of sense with the "FAR" loopback (it is
looping received traffic back into the wire).

> It is running ethtool --test which actually enables
> the loopback, probably by setting BMCR_LOOPBACK. Once the test is
> finished, the bit is cleared and the PHY goes back into normal
> operation.
We are always happy to integrate with any existing functionality, but
as I understand "ethtool --test" then intention is to perform a test
and then bring back the PHY in to a "normal" state (I may be
wrong...).

The idea with this patch is to allow configuring loopback more
"permanently" (userspace can decide when to activate and when to
de-activate). I should properly have made that clear in the cover
letter.

Please let me know what you think.

/Allan
