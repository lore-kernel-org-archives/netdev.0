From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 22:57:02 +0000
Message-ID: <MWHPR12MB1600EA464AF1FBCFB8D41FC8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
        <20170706120214.6076be46@cakuba.netronome.com>
        <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170706154306.143bed14@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Dustin Byford <dustin@cumulusnetworks.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        "olson@cumulusnetworks.com" <olson@cumulusnetworks.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "kubakici@wp.pl" <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0119.outbound.protection.outlook.com ([104.47.42.119]:57952
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752932AbdGFW5F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 18:57:05 -0400
In-Reply-To: <20170706154306.143bed14@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Jakub Kicinski <jakub.kicinski@netronome.com>
| Sent: Thursday, July 6, 2017 3:43 PM
| =A0  =20
| On Thu, 6 Jul 2017 21:53:46 +0000, Casey Leedom wrote:
| >=20
| > But, and far more importantly, ideally _*ANY*_ such decision is made at=
 an
| > architectural level to apply to all Link Parameters and Vendor Products=
.
| > The last thing a user wants to deal with is a hodge-podge of different
| > policies for different adapters from different vendors.
|=20
| Agreed.=A0 Once we decided we should make the expected behaviour very
| clear the everyone.
|=20
| Sorry if I'm misunderstanding - are you suggesting we should keep the
| speed settings if hand-selected?=A0 My feeling is those should be reset
| if they are incompatible with the module.

Again, just to be perfectly clear, I don't think that there's a perfect
solution to this.  My personal feeling is that we need to think through all
of the usage scenarios and see what happens in the various models,
and more importantly, how easily we can explain the inevitable
repercussions to users.  Again, the "simplest model wins" philosophy.

But to your specific question: yes, I am saying that if the user selected
25Gb/s and accidentally swapped in a 10Gb/s cable, and then
swapped a different {100,25}Gb/s cable back in, the advertised
Speed(s) should be 25Gb/s with the newest cable, respecting
the original Link Parameter setting with the first cable.

And again, I don't believe that we'll come up with a perfect solution.
But hopefully we can come up with an abstraction model that's
easy to understand and use.  (And requires the fewest changes
to current accepted practices.)

| Hm.=A0 I'm beginning to come around on this.=A0 If my understanding of PH=
Y
| sub-layers is correct the FEC layer shouldn't be reset on module
| unplug.=A0 OTOH when someone replaces a DAC with an optical module,
| keeping FEC around is not going to do any good to users...

When I first stumbled across this issue several months ago I though
I must be dense.  Nothing this simple should be this complicated.
It's been extremely gratifying to find others similarly flummoxed ... :-)

Casey=
