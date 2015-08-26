From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Wed, 26 Aug 2015 11:36:23 -0700
Message-ID: <55DE0727.5010102@gmail.com>
References: <20150826055215.GA2215@nanopsycho.orion> <20150825.230821.2162893312002303587.davem@davemloft.net> <20150826073757.GB2215@nanopsycho.orion> <20150826.104906.9246591425074015.davem@davemloft.net> <CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35549 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbbHZSix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:38:53 -0400
Received: by pacdd16 with SMTP id dd16so168676537pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:38:53 -0700 (PDT)
In-Reply-To: <CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/08/15 11:21, Scott Feldman wrote:
> On Wed, Aug 26, 2015 at 10:49 AM, David Miller <davem@davemloft.net> wrote:
>> From: Jiri Pirko <jiri@resnulli.us>
>> Date: Wed, 26 Aug 2015 09:37:57 +0200
>>
>>> I don't think that are much more cases like this. Therefore I think that
>>> for this cases, debugfs might be a good way to expose debugging stats.
>>
>> Scott wanted to do similar things in rocker.  DSA guys too.
>>
>> Every switch device is going to have some kind of hierarchy like
>> this, it's not a unique situation.
> 
> We've been able to get buy so far without a user-visible device for
> the switch.  The switch ports are represented by netdevs, so that's
> easy.  How can we create an object for the switch itself, so we can
> attach common interfaces for the user to dump switch-level stats or
> tables?   Using another netdev doesn't seem right.  Do we need a new
> device class for switches, and then create some common tool/interfaces
> for switch device class?

I agree this is something crucially missing. If we try to list what
could be missing currently, there is mostly:

* switch-wide statistics, tables, databases
* controlling a firmware agent running on the switch
* restarting/re-configuring the switch hardware

All of these already have proper ethtool control interfaces, so using
something that understands a specialized net_device might be the easiest
way to go, but we would need a way to put it in the non network device
name space so tools and users to do not get confused?

We could also have a specific SET_NETDEV_DEVTYPE() which helps make that
specific device be part of a "switch-mgmt" class for instance?
-- 
Florian
