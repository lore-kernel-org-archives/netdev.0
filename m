From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH v2.56] datapath: Add basic MPLS support to
 kernel
Date: Fri, 25 Apr 2014 08:24:43 +0900
Message-ID: <20140424232441.GA6282@verge.net.au>
References: <1396323981-20700-2-git-send-email-horms@verge.net.au>
 <20140424085729.CBE6671E58@kuma.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com,
	pshelar@nicira.com, rkerur@gmail.com
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54790 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbaDXXYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 19:24:49 -0400
Content-Disposition: inline
In-Reply-To: <20140424085729.CBE6671E58@kuma.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 05:57:29PM +0900, YAMAMOTO Takashi wrote:
> hi,
> 
> > + * Due to the sample action there may be multiple possible eth types.
> > + * In order to correctly validate actions all possible types are tracked
> > + * and verified. This is done using struct eth_types.
> 
> is there any real-world use cases of these actions inside a sample?
> otherwise, how about just rejecting such combinations?
> it doesn't seem to worth the code complexity to me.
> (sorry if it has been already discussed.  it's the first time for me
> to seriously read this long-lived patch.)

Good point, the code is rather complex.

My understanding is that it comes into effect in the case
of sflow or ipfix being configured on the bridge. I tend
to think these are real-world use-cases, though that thinking
is by no means fixed.

My reading of the code is that in the case of sflow and ipfix a single
sample rule appears at the beginning of the flow. And that it may be
possible to replace the code that you are referring to with something
simpler to handle these cases.

My understanding is that the code you are referring to also comes into
effect when a sample action (a Nicira extension) is used directly in a
rule.  I am less sure that this is a real-world case but the complex logic
you are referring to should to handle this use-case.
