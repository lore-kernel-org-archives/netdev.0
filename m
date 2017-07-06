From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward
 error correction modes
Date: Thu, 6 Jul 2017 12:02:14 -0700
Message-ID: <20170706120214.6076be46@cakuba.netronome.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
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
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:18960 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751813AbdGFTCb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 15:02:31 -0400
In-Reply-To: <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jul 2017 18:53:42 +0000, Casey Leedom wrote:
> However, the first question which pops up is: what happens if a user
> explicitly selects a particular FEC for from the set offered by the
> current Transceiver Module, and then swap out Transceiver Modules to
> one which doesn't support that FEC?  Does the OS/Driver/Firmware
> "forget" the user's FEC setting?  Does it respect it and potentially
> not get a link established?  Do we "temporarily" put the user's FEC
> setting aside?  Or do we have FEC settings per-Transceiver Module
> Type?  Each choice has downsides in terms of "expected behavior" and
> the complexity of the abstraction model offered to the user.
> 
> In our discussions of the above, we decided that we should err in the
> direction of the absolutely simplest abstraction model, even when
> that might result in a failure to establish a link.  Our feeling was
> that doing anything else would result in endless user confusion.
> Basically, if it takes longer than a simple paragraph to explain,
> you're probably doing the wrong thing.  So, we decided that if a user
> sets up a particular FEC setting, we keep that regardless of conflict
> with different Transceiver Modules.  (But flag such issues in the
> System Log in order to try to give the user a chance to understand
> what the new cable they plugged in wasn't working.)

IMHO if something gets replugged all the settings should be reset.
I feel that it's not entirely unlike replugging a USB adapter.  Perhaps
we should introduce some (devlink) notifications for SFP module events
so userspace can apply whatever static user config it has?
