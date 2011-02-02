From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [PATCH v3 1/3] iproute2: add support for setting device groups
Date: Wed, 2 Feb 2011 11:56:58 +0200
Message-ID: <20110202095658.GK2494@cormyr>
References: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
 <1296060086-18777-2-git-send-email-ddvlad@rosedu.org>
 <4D491C3C.2010805@trash.net>
 <20110202091315.GJ2494@cormyr>
 <4D492289.8090708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:40160 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751706Ab1BBJ5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 04:57:05 -0500
Content-Disposition: inline
In-Reply-To: <4D492289.8090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 02, 2011 at 10:23:21AM +0100, Patrick McHardy wrote:
> On 02.02.2011 10:13, Vlad Dogaru wrote:
> > On Wed, Feb 02, 2011 at 09:56:28AM +0100, Patrick McHardy wrote:
> >> On 26.01.2011 17:41, Vlad Dogaru wrote:
> >>> Use the group keyword to specify what group the device should belong to.
> >>> Since the kernel uses numbers internally, mapping of group names to
> >>> numbers is defined in /etc/iproute2/group_map. Example usage:
> >>>
> >>>   ip link set dev eth0 group default
> >>>
> >>> @@ -297,6 +299,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
> >>>  			if (get_integer(&mtu, *argv, 0))
> >>>  				invarg("Invalid \"mtu\" value\n", *argv);
> >>>  			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
> >>> +		} else if (strcmp(*argv, "group") == 0) {
> >>> +			NEXT_ARG();
> >>> +			if (group != -1)
> >>> +				duparg("group", *argv);
> >>> +			if (lookup_map_id(*argv, &group, GROUP_MAP))
> >>> +				invarg("Invalid \"group\" value\n", *argv);
> >>> +			addattr_l(&req->n, sizeof(*req), IFLA_GROUP, &group, 4);
> >>
> >> I think it would be preferrable to use a function similar to
> >> rt_realm_n2a() that can also handle plain numerical values.
> > 
> > The a2n() functions are rather complex for this case: they employ
> > caching and store a table. I suppose this is because multiple calls to
> > them are possible in a single run and the correspondence has to be made
> > in both ways (a2n and n2a).
> > 
> > A network group is only converted to a number at most once for each ip
> > process spawned, so storing a table is not really helpful. What could,
> > however, help is using get_integer before lookup_map_id. Only if
> > get_integer fails would we lookup the symbolic group name.
> 
> Actually that's not entirely correct, the caches are (also) maintained
> to speed up batch mode, in which case there could also be multiple name
> to group mappings.

Both comments noted. I will respin the patches dropping the devgroup
keyword and implementing caching for groups.

Thanks for the feedback.
