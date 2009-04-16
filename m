From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 13:56:49 -0700
Message-ID: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
References: <alpine.DEB.1.10.0904161508520.15835@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	vladislav.yasevich@hp.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:33867 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbZDPU4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 16:56:54 -0400
In-Reply-To: <alpine.DEB.1.10.0904161508520.15835@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well guess then we need the global proc setting after all. With the
> current misbehavior as a default applications need to be rebuilt and

        The current behavior, as either your or Vlad's RFC quotes pointed
out as easily as the history to go with it, is exactly the expected 
behavior
for decades. I think it is not misbehavior so much as your misconception,
though a common one.

> source code that is running on multiple OSes now would have to 
customized
> to special case for Linux.

        No, actually. If you write it for the current behavior, it'll work
fine on an OS like Solaris that has departed from the original socket
behavior. If you're sloppy and don't handle unexpected traffic, it'll be
wrong on both-- you just won't know it until someone runs something with
the same port and multicast address on your network and wrecks your app.

> So add a global proc setting to determine the initial setting of 
IP_MULTICAST_ALL?

        This breaks unknown existing applications that are correctly
written. I think it's clearly wrong to change the behavior of someone
else's socket to match your idea of how it should've been done 25 years
too late. An option that enables new behavior for your own socket, which
must be a new app, is fine. Adding a socket option as part of a port
is no great hurdle, and I'm guessing you aren't trying to run a Solaris
binary on Linux. So what's the problem?

                                                                +-DLS

