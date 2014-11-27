From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 14/21] bridge: add brport flags to dflt bridge_getlink
Date: Thu, 27 Nov 2014 10:46:23 -1000
Message-ID: <CAE4R7bBqAg0CoEcz0s6MKnCH60YEk3EMDD875H_p4GtRhGMGUQ@mail.gmail.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
	<1417084826-9875-15-git-send-email-jiri@resnulli.us>
	<5477244C.2030507@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:36130 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaK0UqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 15:46:25 -0500
Received: by mail-wg0-f46.google.com with SMTP id x12so7323513wgg.19
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 12:46:24 -0800 (PST)
In-Reply-To: <5477244C.2030507@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2014 at 3:17 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/27/14 05:40, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To allow brport device to return current brport flags set on port.  Add
>> returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
>> With this change, netlink msg returned for bridge_getlink contains the
>> port's
>> offloaded flag settings (the port's SELF settings).
>
>
> Am i missing something or we already have this stuff showing up in user
> space today?

For RTM_GETLINK, rtnl_bridge_getlink() calls ndo_bridge_getlink twice
for each dev, once on bridge and second time on dev.  Each call adds
an RTM_NEWLINK to skb.  For the ndo_bridge_getlink() call to bridge,
the MASTER port flags are filled in using br_port_fill_attr().  For
the second ndo_bridge_getlink() call to dev, the port driver calls
ndo_dflt_bridge_getlink() which fills in the SELF port flags.  Before
this patch, ndo_dflt_bridge_getlink() was only filling in hwmode.

Whew, in any case, I think you'll agree this code needs a refactoring
down the road.  This change is just the bare minimum building on
what's there to get SELF port flags up to user-space.  A refactoring
effort should get the port drivers out of parsing/filling netlink msg
and leave that to the core code in rtnetlink.c.  That way we can have
one place for policy checks and one place for fill.  I think this
refactoring effort should be left out in this patch series, otherwise
this is going to drag on into the next year.

>
> cheers,
> jamal
