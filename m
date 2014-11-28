From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 14/21] bridge: add brport flags to dflt bridge_getlink
Date: Fri, 28 Nov 2014 08:07:51 -0500
Message-ID: <547873A7.8010604@mojatatu.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>	<1417084826-9875-15-git-send-email-jiri@resnulli.us>	<5477244C.2030507@mojatatu.com> <CAE4R7bBqAg0CoEcz0s6MKnCH60YEk3EMDD875H_p4GtRhGMGUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:51951 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaK1NH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:07:56 -0500
Received: by mail-ig0-f170.google.com with SMTP id r2so11414371igi.5
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:07:55 -0800 (PST)
In-Reply-To: <CAE4R7bBqAg0CoEcz0s6MKnCH60YEk3EMDD875H_p4GtRhGMGUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/14 15:46, Scott Feldman wrote:
> On Thu, Nov 27, 2014 at 3:17 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>
> For RTM_GETLINK, rtnl_bridge_getlink() calls ndo_bridge_getlink twice
> for each dev, once on bridge and second time on dev.  Each call adds
> an RTM_NEWLINK to skb.  For the ndo_bridge_getlink() call to bridge,
> the MASTER port flags are filled in using br_port_fill_attr().  For
> the second ndo_bridge_getlink() call to dev, the port driver calls
> ndo_dflt_bridge_getlink() which fills in the SELF port flags.  Before
> this patch, ndo_dflt_bridge_getlink() was only filling in hwmode.
>
> Whew, in any case, I think you'll agree this code needs a refactoring
> down the road.  This change is just the bare minimum building on
> what's there to get SELF port flags up to user-space.  A refactoring
> effort should get the port drivers out of parsing/filling netlink msg
> and leave that to the core code in rtnetlink.c.  That way we can have
> one place for policy checks and one place for fill.  I think this
> refactoring effort should be left out in this patch series, otherwise
> this is going to drag on into the next year.
>

I am fine with that. At minimal  br_port_fill_attr() is reusable.

There's a lot of stuff i wish would be "fixed" - one is clearly
not abusing a u8 just to send one bit to the kernel. You just
added one more horn of that sort with the sync learning.
I wish i had time to clean it up. In any case:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
