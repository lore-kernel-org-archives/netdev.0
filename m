From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/5] C/R: Basic support for network namespaces and
 devices (v4)
Date: Tue, 23 Feb 2010 12:49:21 -0600
Message-ID: <20100223184921.GA1101@us.ibm.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
 <1266336187-19105-3-git-send-email-danms@us.ibm.com>
 <20100222194523.GA13135@us.ibm.com>
 <87k4u37vv6.fsf@caffeine.danplanet.com>
 <20100223164755.GA31671@hallyn.com>
 <87fx4r7tgv.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:58809 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab0BWSts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 13:49:48 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1NIhOvl020303
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 11:43:24 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1NInOCF038912
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 11:49:26 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1NInNKK011819
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 11:49:24 -0700
Content-Disposition: inline
In-Reply-To: <87fx4r7tgv.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> But there is no guarantee that the checkpointer is in the netns
> SH> which we would call the 'top level' netns.  Which means that, at
> SH> restart, whether or not the devices which are in what we call the
> SH> top level netns are in fact inherited or not, will depend on
> SH> conditions of the checkpointer.  Do we care?  (I thought we did,
> SH> but maybe we don't... it's unlikely to happen anyway)
> 
> Well, when we discussed this on IRC with Oren, I think we came to the
> conclusion that since network namespaces aren't hierarchical, that we
> would restore things from the "viewpoint" of the process that
> checkpointed them.  It gives us a sane way to ensure that the peer
> devices residing in the init netns can be put back there, even though we
> don't checkpoint everything in the init netns (like eth0).
> 
> If you checkpoint a veth from within the container and you have a peer
> device that is outside the container (but not in a netns that is
> checkpointed as part of a task), it's going to fail and tell you that
> one of your peers leaked to the outside.  I think that's sane and
> preferred behavior, no?

Well I don't think it is, but it's a fine starting point, so let's
worry about it later.

thanks,
-serge

> If you're using macvlan and you checkpoint
> from within the container, I think you should be okay, as long as
> there is a appropriately named device to base the restored devices on
> in whatever netns your restore process is in.
> 
> -- 
> Dan Smith
> IBM Linux Technology Center
> email: danms@us.ibm.com
