From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 2/2] ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE
Date: Wed, 8 Jan 2014 00:09:36 +0100
Message-ID: <20140107230936.GL30393@order.stressinduktion.org>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com> <1389105553-21230-1-git-send-email-thaller@redhat.com> <1389105553-21230-3-git-send-email-thaller@redhat.com> <20140107162847.GB30393@order.stressinduktion.org> <1389119577.2248.16.camel@weing> <20140107190148.GD30393@order.stressinduktion.org> <1389135262.2248.42.camel@weing>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46580 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbaAGXJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:09:37 -0500
Content-Disposition: inline
In-Reply-To: <1389135262.2248.42.camel@weing>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 11:54:22PM +0100, Thomas Haller wrote:
> Hi,
> 
> 
> I think, the modify case is not that hairy and the patch does IMO the
> sensible thing:
> 
> case 1) "change NOPREFIXROUTE -> !NOPREFIXROUTE":
>     update or add prefix route (as before);;
> case 2) "change !NOPREFIXROUTE -> !NOPREFIXROUTE":
>     update or add prefix route (as before);;
> case 3) "change NOPREFIXROUTE -> NOPREFIXROUTE":
>     ;;
> case 4) "change !NOPREFIXROUTE -> NOPREFIXROUTE":
>     cleanup prefix route;;
> 
> where "cleanup" means the same as done in ipv6_del_addr(), as determined
> by check_cleanup_prefix_routes().
> 
> 
> Allowing modify with case 2) and 3) is important. But for case 4) (and
> possibly 1)), we could also fail with error. I tend to the scheme above
> though because it makes it easier for userspace and is likely what it
> wants.
> 
> 
> 
> The problem of deleting a route created by somebody else is already
> present without this patch in ipv6_del_addr. This is indeed a bit shaky,
> but I guess it's good enough in practice. Do I understand correctly,
> that you think about to use the information from ifp->rt to ensure, that
> what we really cleanup the correct route? If that's what you intend, can
> you elaborate a bit on how to do that?

The ifp->rt thing, I thought of, does not work. It only holds the RTF_LOCAL
route (over loopback) which has nothing to do with the prefix route. We don't
have a link from ifp to the prefix route.

Currently I am fine with the semantics you described above but won't
have time to review them today. I'll do that tomorrow.

Thanks,

  Hannes
