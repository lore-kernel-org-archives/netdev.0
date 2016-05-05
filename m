From: Brian Haley <brian.haley@hpe.com>
Subject: Re: [PATCH nf-next 0/9] netfilter: remove per-netns conntrack tables,
 part 1
Date: Thu, 5 May 2016 16:27:15 -0400
Message-ID: <572BACA3.6070303@hpe.com>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5009.houston.hp.com ([15.240.92.67]:53000 "EHLO
	g9t5009.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682AbcEEU1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 16:27:18 -0400
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2016 01:13 PM, Florian Westphal wrote:
> [ CCing netdev so netns folks can have a look too ]
>
> This patch series removes the per-netns connection tracking tables.
> All conntrack objects are then stored in one global global table.
>
> This avoids the infamous 'vmalloc' when lots of namespaces are used:
> We no longer allocate a new conntrack table for each namespace (with 64k
> size this saves 512kb of memory per netns).
>
> - net namespace address is made part of conntrack hash, to spread
>    conntracks over entire table even if netns has overlapping ip addresses.
> - lookup and iterators net_eq() to skip conntracks living in a different
>    namespace.

Hi Florian,

Question on this series.

Openstack networking creates virtual routers using namespaces for isolation 
between users.  VETH pairs are used to connect the interfaces on these routers 
to different networks, whether they are internal (private) or external (public). 
  In most cases NAT is done inside the namespace as packets move between the 
networks.

I've seen cases where certain users are attacked, where the CT table is filled 
such that we start seeing "nf_conntrack: table full, dropping packet" messages 
(as expected).  But other users continue to function normally, unaffected.  Is 
this still the case - each netns has some limit it can't exceed?  I didn't see 
it, but your comment in 9/9 seemed like something was there -  "we would start 
to 'over-subscribe' the affected/overlimit netns".

Thanks,

-Brian
