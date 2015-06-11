From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/3 v2] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Wed, 10 Jun 2015 19:57:14 -0700
Message-ID: <CAE4R7bCTHsjpmHe3BUDARN=b02j5bWwx9bH6mSN3Of7BFpjgEQ@mail.gmail.com>
References: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
 <1433918841-15576-3-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bCy1bZ1A7tUNOA9H2GqwZhjWSqtjzs=GLxUUyNT_3+=gA@mail.gmail.com>
 <CAE4R7bAgBMjeQHpZv8_-h9RnLg2vVLwn537jEKmVQ-A=aY50QQ@mail.gmail.com> <20150611022309.GU588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34954 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbFKC5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 22:57:35 -0400
Received: by qkhq76 with SMTP id q76so34526617qkh.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 19:57:34 -0700 (PDT)
In-Reply-To: <20150611022309.GU588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 7:23 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Wed, Jun 10, 2015 at 07:18:59PM -0700, Scott Feldman wrote:
>> On Wed, Jun 10, 2015 at 7:12 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>> > On Tue, Jun 9, 2015 at 11:47 PM, Andy Gospodarek
>> > <gospo@cumulusnetworks.com> wrote:
>> >
>> >>  /* /proc/sys/net/ipv4/netfilter */
>> >> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
>> >> index 7e7746a..c9d0a0e 100644
>> >> --- a/kernel/sysctl_binary.c
>> >> +++ b/kernel/sysctl_binary.c
>> >> @@ -253,6 +253,7 @@ static const struct bin_table bin_net_ipv4_conf_vars_table[] = {
>> >>         { CTL_INT,      NET_IPV4_CONF_NOPOLICY,                 "disable_policy" },
>> >>         { CTL_INT,      NET_IPV4_CONF_FORCE_IGMP_VERSION,       "force_igmp_version" },
>> >>         { CTL_INT,      NET_IPV4_CONF_PROMOTE_SECONDARIES,      "promote_secondaries" },
>> >> +       { CTL_INT,      NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN,      "ignore_routes_with_linkdown" },
>> >
>> > Would "route_ignore_linkdown_nexthops" be a more accurate name?  The
>> > patch marks link-downed nexthops to be ignored, not the route,
>> > correct?
>> >
>> > s/NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN/NET_IPV4_CONF_ROUTE_IGNORE_LINKDOWN_NEXTHOPS
>>
>> Something like that.  Not sure I like my suggestion.  If dev is
>> nexthop dev in route, and dev is link down, exclude nexthop in route
>> lookup.
>
> I actually played around with a bunch of different names and this was as
> short as I could get it while still conveying the point.  I'm getting
> ready to submit v3, so speak now if you really do hate the name proposed
> in v2.
>
>> route_exclude_if_linkdown_nexthop_dev?
>
> Not bad, but you see what I mean about it being a mouthful.  :)

I think I'd rather see clarity over brevity in this case.  The current
name makes the attr sound like a route property but it's really a prop
of the dev when the dev is a nexthop in a route and the dev link is
down.
