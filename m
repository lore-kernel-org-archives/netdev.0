From: Dan Nicolaescu <dann@ics.uci.edu>
Subject: Re: [patch] add net_device_stats support to ethtool
Date: Wed, 16 Jan 2008 10:34:12 -0800
Message-ID: <200801161834.m0GIYCIr027613@sallyv1.ics.uci.edu>
References: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
	<478E46F6.4070901@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sallyv1.ics.uci.edu ([128.195.1.109]:65447 "EHLO
	sallyv1.ics.uci.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYAPSfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 13:35:47 -0500
In-Reply-To: <478E46F6.4070901@candelatech.com> (Ben Greear's message of "Wed,
	16 Jan 2008 10:03:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

  > Dan Nicolaescu wrote:
  > > Hi,
  > >
  > > I have posted this patch in the past with absolutely no reply.
  > > I would appreciate some sort of feedback of the form interested/not
  > > interested.  Should I just drop it?
  > >
  > >   
  > I like it, but why not offer this for all devices since they all have
  > these stats.
  >
  > Could add new handlers called something like .get_strings_generic, or
  > just add this to the higher-level ethtool handling before it looks for
  > handlers.

If I get your point, then the difference would be that drivers would add
to the initialization of the ethtool structure something like:

         .get_strings_generic = 1;
          
instead of what I originally proposed:

	.get_strings	   = ethtool_op_net_device_stats_get_strings,
	.get_stats_count   = ethtool_op_net_device_stats_get_stats_count,
	.get_ethtool_stats = ethtool_op_net_device_get_ethtool_stats,

Sure that could work, but it would require a few lines of changes in
ethtool.

I can submit a patch that does things that way, if that is considered
better.  But I would like to hear that this code is wanted before
putting any effort in it. I has been ignored for so long... 

Thanks

        --dan
