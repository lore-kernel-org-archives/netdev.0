From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH/RFC repost 2/8] netlink: Allow suppression of
 warnings for duplicate attributes
Date: Fri, 10 Oct 2014 08:31:26 -0700
Message-ID: <20141010153126.GC17859@nicira.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-3-git-send-email-simon.horman@netronome.com>
 <20140926235542.GA20493@nicira.com>
 <20141009011831.GF9339@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:43193 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753236AbaJJPa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 11:30:57 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn15so3101268igb.15
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 08:30:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141009011831.GF9339@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 10:18:32AM +0900, Simon Horman wrote:
> On Fri, Sep 26, 2014 at 04:55:42PM -0700, Ben Pfaff wrote:
> > On Thu, Sep 18, 2014 at 10:55:05AM +0900, Simon Horman wrote:
> > > Add a multiple field to struct nl_policy which if set suppresses
> > > warning of duplicate attributes in nl_parse_nested().
> > > 
> > > As is the case without this patch only the last occurrence of an
> > > attribute is stored in attrs by nl_parse_nested(). As such
> > > if the multiple field of struct nl_policy is set then it
> > > is up to the caller to parse the message to extract all the attributes.
> > > 
> > > This is in preparation for allowing multiple OVS_SELECT_GROUP_ATTR_BUCKET
> > > attributes in a nested OVS_ACTION_ATTR_SELECT_GROUP attribute.
> > > 
> > > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > 
> > In the other case where we have duplicate attributes, it doesn't make
> > sense to process them with the policy functions, because we want to
> > see all of the instances of the duplicate attributes and policy
> > doesn't allow us to do that.  I'm a little surprised that the new
> > attributes work differently.  What's the idea?
> 
> My idea was to use the policy to obtain the attributes that
> may not be duplicated. And then custom code to pick up all the
> instances of attributes that may be duplicated.
> 
> I'm don't feel strongly about that approach and I'd be just has
> happy to drop this patch and rework things a little so that
> all the attributes are picked out by custom code. It sounds
> like that would match the approach taken elsewhere. Sorry for
> not noticing that earlier.

I see.

That's more like the approach used elsewhere, yes, but in those cases
there wasn't anything (if I recall correctly) that could be usefully
done with the policy parser, so it wasn't considered as an option.  If
the group buckets are different then maybe a different treatment is
warranted.
