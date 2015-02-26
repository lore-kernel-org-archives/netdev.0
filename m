From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Thu, 26 Feb 2015 06:19:27 -0800
Message-ID: <CAE4R7bBspZn3Mt2-KGeBBCfkxOQAmFFoOZJAnTKJBNPkS9P2Lg@mail.gmail.com>
References: <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<20150225154607.GD1332@gospo.home.greyhouse.net>
	<CAE4R7bB0ZqjA+2C7EL7fe0o1fvzoNofMmZsbD6FK4_ZYKXdrhg@mail.gmail.com>
	<20150226042158.GF1332@gospo.home.greyhouse.net>
	<20150226064755.GA2074@nanopsycho.orion>
	<20150226141319.GA7971@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	"Rafa?? Mi??ecki" <zajec5@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:33553 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbBZOT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:19:28 -0500
Received: by qcxm20 with SMTP id m20so8559375qcx.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:19:27 -0800 (PST)
In-Reply-To: <20150226141319.GA7971@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 6:13 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Thu, Feb 26, 2015 at 07:47:55AM +0100, Jiri Pirko wrote:
>> Thu, Feb 26, 2015 at 05:21:58AM CET, gospo@cumulusnetworks.com wrote:
>> >On Wed, Feb 25, 2015 at 04:53:24PM -0800, Scott Feldman wrote:
>> >> On Wed, Feb 25, 2015 at 7:46 AM, Andy Gospodarek
>> >> <gospo@cumulusnetworks.com> wrote:
>> >> > On Wed, Feb 25, 2015 at 03:03:56PM +0100, Andrew Lunn wrote:
>> >> > [...]
>> >> >>
>> >> >> What we don't want is X chip families and Y different ways to
>> >> >> configure the features. Ideal we want X chip families, and one way to
>> >> >> configure them all.
>> >> >
>> >> > This statement is really my primary concern.  There is lots of interest
>> >> > around hardware offload at this point and it seems like there is a risk
>> >> > that a lack of consistency can create problems.
>> >> >
>> >> > I think these patches are great as they allow for the programming of the
>> >> > offload hardware (and it has been pointed out that this drastically
>> >> > increases performance), but one concern I have with this patch (related
>> >> > to this) is that I'm not sure there is a major need to create netdevs
>> >> > automatically if there is not the ability to rx/tx actual frames on
>> >> > these interfaces.
>> >>
>> >> Even when not used for rx/tx to CPU, it seems the netdevs are still
>> >> useful as an anchor to build higher-level constructs such as bridge or
>> >> bond, and to hang stuff like netdev stats or ethtool-ish things.
>> >>
>> >
>> >I agree that they are useful, but now we are really dealing with a
>> >netdev that is slightly lower functionality than we expect from a netdev
>> >right now.
>>
>> Is that a real care for some device now?
> I guess that depends on how users expect to use it.  :)
>
>> I agree with Scott that we need to model is consistently. If there is
>> such port netdev witch cannot tx/rx, we can expose the fact using some
>> flag...
> Using a flag to expose/mark this was exactly my thought.

Missing .ndo_start_xmit is the clue....do we need more?
