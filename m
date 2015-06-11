From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3 v3] net: track link-status of ipv4 nexthops
Date: Thu, 11 Jun 2015 07:23:14 -0400
Message-ID: <20150611112313.GA588@gospo.home.greyhouse.net>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bAnPDA_S=tjaM-qLbb4ZM0_FcTPQH6jC7_Mgmc==1c6wA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33306 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbbFKLXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 07:23:19 -0400
Received: by qgfa66 with SMTP id a66so1138860qgf.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 04:23:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAnPDA_S=tjaM-qLbb4ZM0_FcTPQH6jC7_Mgmc==1c6wA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 11:07:28PM -0700, Scott Feldman wrote:
> On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
> > reachable via an interface where carrier is off.  No action is taken,
> > but additional flags are passed to userspace to indicate carrier status.
> 
> Andy, it seems now RTNH_F_LINKDOWN and RTNH_F_DEAD are very similar
> and I'm wondering if this could be done without introducing a new flag
> and just use RTNH_F_DEAD.  The link change event would set RTNH_F_DEAD
> on nh on dev link down, and clear on link up.  The sysctl knob would
> be something like "nexthop_dead_on_linkdown", default off.  So
> basically expanding the ways RTNH_F_DEAD can be set.  That would
> simplify the patch set quite a bit and require no changes to iproute2.
> 

You are absolutely correct that what you describe would be less churn to
userspace.  From a functionality standpoint that is close to what was
originally proposed, but Alex specifically did not like the behavioral
change to what having RTNH_F_DEAD set (at least that was what I
understood).

That was what made me make the move to add this additional flag that was
exported to userspace, so it was possible to differentiate the old dead
routes/nexthop functionality from those that were not going to be dead
due to link being down.  

At this point I think I prefer the additional data provided by the new
flag exported to userspace.
