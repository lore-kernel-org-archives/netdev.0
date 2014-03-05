From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 2/2] 6lowpan: reassembly: fix kernel oops while
 unloading
Date: Wed, 5 Mar 2014 23:32:46 +0100
Message-ID: <20140305223246.GA17526@breakpoint.cc>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
 <1394052211-6976-3-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37272 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932478AbaCEWcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 17:32:50 -0500
Content-Disposition: inline
In-Reply-To: <1394052211-6976-3-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Aring <alex.aring@gmail.com> wrote:
> It seems that the inet_frag_queue is deleted but the timer is running. This
> patch adds a for loop to iterate over all frag_queue entries in the
> frag_bucket and calling del_timer for each frag_queue entry while
> unloading the 6lowpan module.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> Reported-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> ---
> I am not sure about that I can do that in this simply way without hold
> any lock of the inet_frag_queue or inet_frag_bucket. Please help there.
> The kernel oops never occurs afterwards, but this isn't simple to test.
> I can't test all cases.

I find it hard to believe that this is a 6lowpan specific problem,
most likely this needs a fix in inet_fragment code.

I am currently looking at that code for different reasons anyway and can
investigate tomorrow if you do not have time for it.
