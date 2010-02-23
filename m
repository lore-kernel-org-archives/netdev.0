From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/5] C/R: Basic support for network namespaces and devices (v4)
Date: Tue, 23 Feb 2010 08:35:57 -0800
Message-ID: <87k4u37vv6.fsf@caffeine.danplanet.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	<1266336187-19105-3-git-send-email-danms@us.ibm.com>
	<20100222194523.GA13135@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:44944 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753098Ab0BWQgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 11:36:09 -0500
In-Reply-To: <20100222194523.GA13135@us.ibm.com> (Serge E. Hallyn's message of "Mon\, 22 Feb 2010 13\:45\:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> the above two hunks change the flow in checkpoint_container(), but
SH> they don't seem to actually add anything.  And I don't see (with a
SH> quick browse) any later patch in this series changing this either.
SH> Is this just noise?

Ah, yeah, I think that's left over from a previous version where I had
to insert something there.  Sorry about that :)

>> +int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev)
>> +{
>> +	return dev->nd_net == current->nsproxy->net_ns;
>> +}

SH> You are comparing it to the net_ns of the checkpointing task.  I'm
SH> not sure that makes sense - but I'm also not sure what if anything
SH> makes more sense.

SH> What exactly do you mean by the 'init' netns here?  Do you mean
SH> the init_net_ns for the container, or that it is the net_ns of
SH> whatever task created the container?

In this case, 'current' is the task doing the checkpoint, right?  So,
we're treating the netns that it is in as the "top level" and will
restore the tree, as visible from that task, relative to the netns of
the restart process.  We had an IRC conversation about this, I believe :)

SH> How about a
SH> 			ckpt_err(ctx, -ENOSYS,
SH> 				Device %s does not support checkpoint\n",
dev-> name);

SH> here to put a meaningful msg in the user's log?

Yep, definitely.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
