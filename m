From: Gal Pressman <galp@mellanox.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 29 Jun 2017 18:49:58 +0300
Message-ID: <7459c555-c8d7-52eb-40bc-78eeca6c76f0@mellanox.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <11d024ad-6e09-e475-a448-e79b6eef5654@mellanox.com>
 <20170628054610.rirfrvzdwwmh3isg@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        jeffrey.t.kirsher@intel.com
To: Dustin Byford <dustin@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0088.outbound.protection.outlook.com ([104.47.0.88]:10880
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753117AbdF2PuO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 11:50:14 -0400
In-Reply-To: <20170628054610.rirfrvzdwwmh3isg@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Gal,
>
> ...
>> What is the difference between the information in ethtool DEVNAME and ethtool --show-fec DEVNAME?
> I think there are two questions there.  First, how does the FEC-related
> information from glinksettings differ from what's retrieved via
> gfecparam.  Second, how is that expressed through the ethtool UI.
>
> Regarding the uapi (as we imagined it), glinksettings returns FEC
> information through three fields:
>
> @supported: the complete set of FEC modes the hardware supports, at any
> speed, medium, or autoneg combination.
>
> @advertising: the set of modes advertised to the link partner through
> the relevant autoneg mechanism.
>
> @lp_advertising: the set of modes the link partner is advertising
> through autoneg.
>
>
> gfecparam is used to fetch a couple more important facts about the FEC
> configuration:
>
> 1) What FEC mode is currently active, either as a result of the autoneg
> process, or a previous call to sfecparam.  This is returned in
> sfecparam->active_fec
>
> 2) If autoneg is off, what is the currently configured FEC mode.  This
> is a bitmask returned in gfecparam->fec.  I imagine it's typically a
> single mode, but a mask makes it easier to implement a "don't care" policy,
> or otherwise allow the NIC/driver to pick between a set of modes.
>
>
> Regarding the UI.  ethtool DEVNAME gets most of its info from
> glinksettings and it's easy to represent the FEC parameters affected by
> autoneg there.  ethtool --show-fec simply reports the output of
> gfecparam.  I agree the difference is subtle, perhaps it makes sense to
> combine all the FEC information into ethtool DEVNAME?
IMHO it does, but the current UI is fine too.
Thanks for the explanation.
