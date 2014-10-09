From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH/RFC repost 2/8] netlink: Allow suppression of
 warnings for duplicate attributes
Date: Thu, 9 Oct 2014 10:18:32 +0900
Message-ID: <20141009011831.GF9339@vergenet.net>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-3-git-send-email-simon.horman@netronome.com>
 <20140926235542.GA20493@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:54053 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaJIBSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 21:18:42 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so1256190igc.6
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 18:18:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140926235542.GA20493@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 04:55:42PM -0700, Ben Pfaff wrote:
> On Thu, Sep 18, 2014 at 10:55:05AM +0900, Simon Horman wrote:
> > Add a multiple field to struct nl_policy which if set suppresses
> > warning of duplicate attributes in nl_parse_nested().
> > 
> > As is the case without this patch only the last occurrence of an
> > attribute is stored in attrs by nl_parse_nested(). As such
> > if the multiple field of struct nl_policy is set then it
> > is up to the caller to parse the message to extract all the attributes.
> > 
> > This is in preparation for allowing multiple OVS_SELECT_GROUP_ATTR_BUCKET
> > attributes in a nested OVS_ACTION_ATTR_SELECT_GROUP attribute.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> In the other case where we have duplicate attributes, it doesn't make
> sense to process them with the policy functions, because we want to
> see all of the instances of the duplicate attributes and policy
> doesn't allow us to do that.  I'm a little surprised that the new
> attributes work differently.  What's the idea?

My idea was to use the policy to obtain the attributes that
may not be duplicated. And then custom code to pick up all the
instances of attributes that may be duplicated.

I'm don't feel strongly about that approach and I'd be just has
happy to drop this patch and rework things a little so that
all the attributes are picked out by custom code. It sounds
like that would match the approach taken elsewhere. Sorry for
not noticing that earlier.
