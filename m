From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [PATCH 3/3] netlink: support setting devgroup parameters
Date: Tue, 11 Jan 2011 14:13:50 +0200
Message-ID: <20110111121350.GB26417@cormyr>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
 <1294659524-22509-4-git-send-email-ddvlad@rosedu.org>
 <1294665273.6063.292.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:54238 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755812Ab1AKMPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 07:15:03 -0500
Content-Disposition: inline
In-Reply-To: <1294665273.6063.292.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 08:14:33AM -0500, jamal wrote:
> 
> Nice - short and sweet.
> 
> IMO: I dont think you need this new attribute, IFLA_GROUP
> should suffice...
> You can use the trick that if a <=0 ifindex is specified,
> and no name is passed but a GROUP is passed, then we
> operate on the group i.e something like:
> 
>         if (ifm->ifi_index > 0)
>                 dev = __dev_get_by_index(net, ifm->ifi_index);
>         else {
>                 if (tb[IFLA_IFNAME])
>                      dev = __dev_get_by_name(net, ifname);
>                 else if (tb[IFLA_GROUP])
>                      new/get/set/del specific stuff..
>                 else
>                    return -EINVAL;
>        }

That sounds like a good idea, but, by using the same attribute,
userspace won't be able to change the group of all the interfaces in a
group, i.e. no more
	ip l set group 1 devgroup 0

However, I'm not sure that the use case above would be very common.

Vlad
