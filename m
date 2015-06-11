From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3 v3] net: ipv4 sysctl option to ignore
 routes when nexthop link is down
Date: Wed, 10 Jun 2015 21:32:46 -0700 (PDT)
Message-ID: <20150610.213246.909418500696941374.davem@davemloft.net>
References: <5578F92B.8060604@miraclelinux.com>
	<CAE4R7bCXehOuybGyDMHmzEHw_4X7d3G345EXYCyMCrC7c4oe8g@mail.gmail.com>
	<20150611033621.GZ588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, hideaki.yoshifuji@miraclelinux.com,
	netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbbFKEct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 00:32:49 -0400
In-Reply-To: <20150611033621.GZ588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Wed, 10 Jun 2015 23:36:21 -0400

> On Wed, Jun 10, 2015 at 08:00:14PM -0700, Scott Feldman wrote:
>> On Wed, Jun 10, 2015 at 7:57 PM, YOSHIFUJI Hideaki
>> <hideaki.yoshifuji@miraclelinux.com> wrote:
>> > Hi,
>> >
>> > Andy Gospodarek wrote:
>> >> This feature is only enabled with the new per-interface or ipv4 global
>> >> sysctls called 'ignore_routes_with_linkdown'.
>> >>
>> >> net.ipv4.conf.all.ignore_routes_with_linkdown = 0
>> >> net.ipv4.conf.default.ignore_routes_with_linkdown = 0
>> >> net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
>> > :
>> >> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> >> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
>> >> ---
>> > :
>> >> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
>> >> index 7e7746a..c9d0a0e 100644
>> >> --- a/kernel/sysctl_binary.c
>> >> +++ b/kernel/sysctl_binary.c
>> >> @@ -253,6 +253,7 @@ static const struct bin_table bin_net_ipv4_conf_vars_table[] = {
>> >>       { CTL_INT,      NET_IPV4_CONF_NOPOLICY,                 "disable_policy" },
>> >>       { CTL_INT,      NET_IPV4_CONF_FORCE_IGMP_VERSION,       "force_igmp_version" },
>> >>       { CTL_INT,      NET_IPV4_CONF_PROMOTE_SECONDARIES,      "promote_secondaries" },
>> >> +     { CTL_INT,      NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN,      "ignore_routes_with_linkdown" },
>> >>       {}
>> >>  };
>> >>
>> >
>> > Please do not add new binary sysctl knob. Thank you.
>> 
>> Reason?
> 
> I'll echo Scott's request here.  I realize than an abundance of them is
> bad, but (to me) this one seems useful.  Unless of course we want to
> make this proposed behavior the default.  :-)

Kernel wide, new binary sysctl's are verboten.

Everyone should be accessing sysctls via their name.

You have to remove this.
