From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 21:53:46 +0000
Message-ID: <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170706120214.6076be46@cakuba.netronome.com>
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
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0102.outbound.protection.outlook.com ([104.47.42.102]:45216
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752865AbdGFVyO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 17:54:14 -0400
In-Reply-To: <20170706120214.6076be46@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Jakub Kicinski <kubakici@wp.pl>
| Sent: Thursday, July 6, 2017 12:02 PM
|
| IMHO if something gets replugged all the settings should be reset.
| I feel that it's not entirely unlike replugging a USB adapter.  Perhaps
| we should introduce some (devlink) notifications for SFP module events
| so userspace can apply whatever static user config it has?

Absolutely a valid approach.  As are all of the ones I outlined.

But, and far more importantly, ideally _*ANY*_ such decision is made at an
architectural level to apply to all Link Parameters and Vendor Products.
The last thing a user wants to deal with is a hodge-podge of different
policies for different adapters from different vendors.
=20
As I noted in my previous letter: this is something new that we've never
faced before with any prior networking technology.  All previous networking
technologies had a static set of Physical Port Capabilities fixed from the
moment a Host Diver/Firmware first see a Port.  We're now facing a situatio=
n
where these can change dynamically from moment to moment based on what
Transceiver Module is inserted.

With regard to this "architectural" issue, one way of trying to tease out
what model will be the simplest for users to work with is to ask: how do
users conceive of a "Port"?  I.e. when a user requests that a particular
Link Parameter be applied to a Port, are they thinking that it only applies
to the current instantaneous combination of Adapter Transceiver Module Cage
+ Transceiver Module?  Or do they conceptualize a "Port" as being a higher
level entity?

Or, let's make it Very Concrete with a specific example:

 1. User applies some set of Link Parameters.

 2. User attempts to bring Link up but it doesn't come up.

 3. User decides to try a different cable on the grounds that the first
    cable may be bad.

 4. New cable is accidentally of a completely different type with completel=
y
    different subsequent Physical Port Capabilities, not capable of support=
ing
    the user's selected Link Parameters.

 5. User realizes this accidental mis-selection, and swaps in a third cable=
,
    similar to the first cable.

 6. User attempts to bring the Link up with the third cable.

If we reset all of the user-specified Link Parameters at point #3 and/or #5=
,
then the user's requested Link Parameter settings from point #1 will no
longer be in effect at point #6.  Is this expected/desirable?

In our discussions (Dustin, I, and others), we felt that the answer to this
above scenario question was "no".  I.e. that users would have a persistent
memory of having applied a set of Link Parameter settings to the "Port" and
would be annoyed/confused if those settings were "arbitrarily" reset at som=
e
indefinite time.

But, this is a discussion and a decision that needs to be made.  Regardless
of what people finally decide is the "Right Answer", it needs to be
extremely well documented, it needs to be executed uniformly, and we may
want to explicitly notify the user at the points where something
unexpected/confusing is occurring.  Say, in the "Reset Unsupportable Link
Parameters When Transceiver Module Is Changed" model that you advocate, whe=
n
the user's Link Parameter settings are reset.

Casey
