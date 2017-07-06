From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 22:47:06 +0000
Message-ID: <MWHPR12MB1600B8ECA4222A062CDC71C0C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170706223324.GA24237@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Dustin Byford <dustin@cumulusnetworks.com>,
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
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0105.outbound.protection.outlook.com ([104.47.42.105]:5178
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751619AbdGFWrL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 18:47:11 -0400
In-Reply-To: <20170706223324.GA24237@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Andrew Lunn <andrew@lunn.ch>
| Sent: Thursday, July 6, 2017 3:33 PM
| =A0  =20
| On Thu, Jul 06, 2017 at 09:53:46PM +0000, Casey Leedom wrote:
| >=20
| > But, and far more importantly, ideally _*ANY*_ such decision is made at=
 an
| > architectural level to apply to all Link Parameters and Vendor Products=
.
| > The last thing a user wants to deal with is a hodge-podge of different
| > policies for different adapters from different vendors.
|=20
| Yes.
|=20
| SFP needs to becomes a Linux device, similar to Copper PHYs are Linux
| devices. With some core code which all drivers can use, implement
| ethtool --dump-module-eeprom, report speeds to the MAC using
| adjust_link, etc..

Okay.  This "feels" like an implementation approach rather than a model
abstraction commentary, but it sounds like it would help ensure consistency
across vendors, etc.

| > how do users conceive of a "Port"?
|=20
| For a user, it is something they configure via /etc/network/interfaces
| and then use ifup/ifdown on.
|=20
| ...
|=20
| And this is where it gets interesting, as you say. We are into a
| hotplug model.
|=20
| I think you also need to define 'cable' here. I assume you are not
| talking about a piece of CAT 5 or glass fibre. You mean something
| which is active. You are putting a different module into the SFP cage.

Yes, I'm talking about active Transceiver Modules whether welded
onto the ends of copper-based cables or Optical Transceiver Modules.

| The extreme model would be, if you pull the module out, the whole
| netdev is hot-unplugged. Plug a different modules in, the netdev is
| hot-plugged. The user has to ifup it again, and would get an error
| message if the configuration is invalid.
|=20
| But i think this is too extreme.

I agree.  This would force a completely new set of behavior on all users.
And it wouldn't match the paradigms used by any other OS.  (Yes,
I know that Linux tends to ignore such issues, but users do live in
mixed shops and it would be cruel to them to force radically different
operating paradigms between the systems they need to use.)

| I think the sfp device needs to give a hotplug event on unplug/plug.
| A hot-unplug would result in an ifdown. And within the kernel, the
| netdev is set down. If there is an "allow-hotplug" statement in
| /etc/network/interfaces, on hot-plug, udev would try to ifup and get
| an error and it will stay down. Without the "allow-hotplug" the
| interface remains configured down until the user does an ifup and
| would see an error message if the configuration is invalid.

Even this feels too extreme for me.  I think users would hate it.  They
did an ifup and swapped cables.  They expect the OS/Driver/Firmware
to continue trying to honor their ifup request.

Casey=
