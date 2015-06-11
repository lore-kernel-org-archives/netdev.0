From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3 v3] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Thu, 11 Jun 2015 15:35:55 -0400
Message-ID: <20150611193554.GC588@gospo.home.greyhouse.net>
References: <5578F92B.8060604@miraclelinux.com>
 <CAE4R7bCXehOuybGyDMHmzEHw_4X7d3G345EXYCyMCrC7c4oe8g@mail.gmail.com>
 <20150611033621.GZ588@gospo.home.greyhouse.net>
 <20150610.213246.909418500696941374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, hideaki.yoshifuji@miraclelinux.com,
	netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35779 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbbFKTf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 15:35:58 -0400
Received: by qkhq76 with SMTP id q76so7506894qkh.2
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 12:35:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150610.213246.909418500696941374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 09:32:46PM -0700, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Wed, 10 Jun 2015 23:36:21 -0400
> 
> > On Wed, Jun 10, 2015 at 08:00:14PM -0700, Scott Feldman wrote:
> >> On Wed, Jun 10, 2015 at 7:57 PM, YOSHIFUJI Hideaki
> >> <hideaki.yoshifuji@miraclelinux.com> wrote:
> >> > Hi,
> >> >
> >> > Andy Gospodarek wrote:
> >> >> This feature is only enabled with the new per-interface or ipv4 global
> >> >> sysctls called 'ignore_routes_with_linkdown'.
> >> >>
> >> >> net.ipv4.conf.all.ignore_routes_with_linkdown = 0
> >> >> net.ipv4.conf.default.ignore_routes_with_linkdown = 0
> >> >> net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
> >> > :
> >> >> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> >> >> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> >> >> ---
> >> > :
> >> >> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> >> >> index 7e7746a..c9d0a0e 100644
> >> >> --- a/kernel/sysctl_binary.c
> >> >> +++ b/kernel/sysctl_binary.c
> >> >> @@ -253,6 +253,7 @@ static const struct bin_table bin_net_ipv4_conf_vars_table[] = {
> >> >>       { CTL_INT,      NET_IPV4_CONF_NOPOLICY,                 "disable_policy" },
> >> >>       { CTL_INT,      NET_IPV4_CONF_FORCE_IGMP_VERSION,       "force_igmp_version" },
> >> >>       { CTL_INT,      NET_IPV4_CONF_PROMOTE_SECONDARIES,      "promote_secondaries" },
> >> >> +     { CTL_INT,      NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN,      "ignore_routes_with_linkdown" },
> >> >>       {}
> >> >>  };
> >> >>
> >> >
> >> > Please do not add new binary sysctl knob. Thank you.
> >> 
> >> Reason?
> > 
> > I'll echo Scott's request here.  I realize than an abundance of them is
> > bad, but (to me) this one seems useful.  Unless of course we want to
> > make this proposed behavior the default.  :-)
> 
> Kernel wide, new binary sysctl's are verboten.
> 
> Everyone should be accessing sysctls via their name.
> 
> You have to remove this.
> 

No problem, the code as-is works just fine without, so I'll submit a v4
with this line removed.
