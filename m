From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward
 error correction modes
Date: Thu, 6 Jul 2017 15:43:06 -0700
Message-ID: <20170706154306.143bed14@cakuba.netronome.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
        <20170706120214.6076be46@cakuba.netronome.com>
        <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Casey Leedom <leedom@chelsio.com>, kubakici@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33366 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdGFWnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 18:43:10 -0400
Received: by mail-pf0-f180.google.com with SMTP id e7so7639576pfk.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 15:43:09 -0700 (PDT)
In-Reply-To: <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jul 2017 21:53:46 +0000, Casey Leedom wrote:
> | From: Jakub Kicinski <kubakici@wp.pl>
> | Sent: Thursday, July 6, 2017 12:02 PM
> |
> | IMHO if something gets replugged all the settings should be reset.
> | I feel that it's not entirely unlike replugging a USB adapter.  Perhaps
> | we should introduce some (devlink) notifications for SFP module events
> | so userspace can apply whatever static user config it has?
> 
> Absolutely a valid approach.  As are all of the ones I outlined.
> 
> But, and far more importantly, ideally _*ANY*_ such decision is made at an
> architectural level to apply to all Link Parameters and Vendor Products.
> The last thing a user wants to deal with is a hodge-podge of different
> policies for different adapters from different vendors.

Agreed.  Once we decided we should make the expected behaviour very
clear the everyone.

Sorry if I'm misunderstanding - are you suggesting we should keep the
speed settings if hand-selected?  My feeling is those should be reset
if they are incompatible with the module.

> As I noted in my previous letter: this is something new that we've never
> faced before with any prior networking technology.  All previous networking
> technologies had a static set of Physical Port Capabilities fixed from the
> moment a Host Diver/Firmware first see a Port.  We're now facing a situation
> where these can change dynamically from moment to moment based on what
> Transceiver Module is inserted.
> 
> With regard to this "architectural" issue, one way of trying to tease out
> what model will be the simplest for users to work with is to ask: how do
> users conceive of a "Port"?  I.e. when a user requests that a particular
> Link Parameter be applied to a Port, are they thinking that it only applies
> to the current instantaneous combination of Adapter Transceiver Module Cage
> + Transceiver Module?  Or do they conceptualize a "Port" as being a higher
> level entity?

Hm.  I'm beginning to come around on this.  If my understanding of PHY
sub-layers is correct the FEC layer shouldn't be reset on module
unplug.  OTOH when someone replaces a DAC with an optical module,
keeping FEC around is not going to do any good to users...
