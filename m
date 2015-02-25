From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Wed, 25 Feb 2015 10:46:07 -0500
Message-ID: <20150225154607.GD1332@gospo.home.greyhouse.net>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
 <20150224223039.GC1332@gospo.home.greyhouse.net>
 <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
 <54ED017E.6000902@gmail.com>
 <20150225001534.GB15633@lunn.ch>
 <54ED19AB.7020003@gmail.com>
 <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
 <20150225140356.GB17992@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rafa?? Mi??ecki <zajec5@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:38792 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173AbbBYPqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:46:12 -0500
Received: by mail-qg0-f46.google.com with SMTP id z107so3600801qgd.5
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 07:46:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150225140356.GB17992@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 03:03:56PM +0100, Andrew Lunn wrote:
[...]
> 
> What we don't want is X chip families and Y different ways to
> configure the features. Ideal we want X chip families, and one way to
> configure them all.

This statement is really my primary concern.  There is lots of interest
around hardware offload at this point and it seems like there is a risk
that a lack of consistency can create problems.

I think these patches are great as they allow for the programming of the
offload hardware (and it has been pointed out that this drastically
increases performance), but one concern I have with this patch (related
to this) is that I'm not sure there is a major need to create netdevs
automatically if there is not the ability to rx/tx actual frames on
these interfaces.

Since the SoC's NIC is going to handle all packet rx/tx then it seems
like there should be a way to signal between the switching
hardware/driver and the NIC driver.  I'm not sure what the ideal
interface for this is, but maybe there is room in the switchdev infra
add some ops to find a way to make this signalling possible to create
netdevs and allow incoming traffic to be assigned to the appropriate
device.
