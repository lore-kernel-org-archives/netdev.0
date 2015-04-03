From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH 1/5] geneve: remove MODULE_ALIAS_RTNL_LINK from
 net/ipv4/geneve.c
Date: Fri, 3 Apr 2015 10:27:05 -0400
Message-ID: <20150403142704.GA31348@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-2-git-send-email-linville@tuxdriver.com>
 <20150402163919.7b07039a@urahara>
 <20150403121755.GC16847@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59620 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbbDCOaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 10:30:24 -0400
Content-Disposition: inline
In-Reply-To: <20150403121755.GC16847@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2015 at 02:17:55PM +0200, Jiri Pirko wrote:
> Fri, Apr 03, 2015 at 01:39:19AM CEST, stephen@networkplumber.org wrote:
> >On Thu,  2 Apr 2015 15:17:02 -0400
> >"John W. Linville" <linville@tuxdriver.com> wrote:
> >
> >> This file is essentially a library for implementing the geneve
> >> encapsulation protocol.  The file does not register any rtnl_link_ops,
> >> so the MODULE_ALIAS_RTNL_LINK macro is inappropriate here.
> >> 
> >> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> >> ---
> >>  net/ipv4/geneve.c | 1 -
> >>  1 file changed, 1 deletion(-)
> >> 
> >> diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
> >> index 5a4828ba05ad..ba5283adbee8 100644
> >> --- a/net/ipv4/geneve.c
> >> +++ b/net/ipv4/geneve.c
> >> @@ -450,4 +450,3 @@ module_exit(geneve_cleanup_module);
> >>  MODULE_LICENSE("GPL");
> >>  MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
> >>  MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
> >> -MODULE_ALIAS_RTNL_LINK("geneve");
> >
> >ok but then how does it get autoloaded?
> 
> There is no "struct rtnl_link_ops" defined for this. Therefore this does
> not have any sense. User might use rtnl to load the module, but why?
> That is clearly a bug which John is fixing.

Yes, exactly.  This module gets loaded via the depmod/modprobe magic
that handles loading modules to resolve external references during
the loadtime linking.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
