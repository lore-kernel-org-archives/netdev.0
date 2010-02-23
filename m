From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/5] C/R: Basic support for network namespaces and devices (v4)
Date: Tue, 23 Feb 2010 09:27:44 -0800
Message-ID: <87fx4r7tgv.fsf@caffeine.danplanet.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	<1266336187-19105-3-git-send-email-danms@us.ibm.com>
	<20100222194523.GA13135@us.ibm.com>
	<87k4u37vv6.fsf@caffeine.danplanet.com>
	<20100223164755.GA31671@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:45068 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751216Ab0BWR1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 12:27:47 -0500
In-Reply-To: <20100223164755.GA31671@hallyn.com> (Serge E. Hallyn's message of "Tue\, 23 Feb 2010 10\:47\:55 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> But there is no guarantee that the checkpointer is in the netns
SH> which we would call the 'top level' netns.  Which means that, at
SH> restart, whether or not the devices which are in what we call the
SH> top level netns are in fact inherited or not, will depend on
SH> conditions of the checkpointer.  Do we care?  (I thought we did,
SH> but maybe we don't... it's unlikely to happen anyway)

Well, when we discussed this on IRC with Oren, I think we came to the
conclusion that since network namespaces aren't hierarchical, that we
would restore things from the "viewpoint" of the process that
checkpointed them.  It gives us a sane way to ensure that the peer
devices residing in the init netns can be put back there, even though we
don't checkpoint everything in the init netns (like eth0).

If you checkpoint a veth from within the container and you have a peer
device that is outside the container (but not in a netns that is
checkpointed as part of a task), it's going to fail and tell you that
one of your peers leaked to the outside.  I think that's sane and
preferred behavior, no?  If you're using macvlan and you checkpoint
from within the container, I think you should be okay, as long as
there is a appropriately named device to base the restored devices on
in whatever netns your restore process is in.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
