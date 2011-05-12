From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
 not interacting well with multicast in 2.6.38-4
Date: Thu, 12 May 2011 16:28:10 -0700
Message-ID: <20110512162810.34b8d55a@nehalam>
References: <20110510180540.GI6397@morgul.net>
	<20110510151100.52a9f8fa@nehalam>
	<20110510233540.GJ6397@morgul.net>
	<20110512.155916.115945119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: noahm@debian.org, ben@decadent.org.uk, 625914@bugs.debian.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46138 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757801Ab1ELX3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:29:11 -0400
In-Reply-To: <20110512.155916.115945119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 May 2011 15:59:16 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Noah Meyerhans <noahm@debian.org>
> Date: Tue, 10 May 2011 16:35:40 -0700
> 
> > On Tue, May 10, 2011 at 03:11:00PM -0700, Stephen Hemminger wrote:
> >> There were two more follow on commits in stable related to this.
> >> I recommend merging 2.6.38.6 which includes these.
> > 
> > The problem still exists in the current 2.6.38.6.  Backing out 5f1c356a
> > still solves the problem there.
> > 
> > I have not yet tried anything outside the stable-2.6.38.y tree, but it
> > seems like these same changes are present there, and it's unlikely that
> > other releases will work any better.
> 
> So the issue is that if we back out that change, we get crashes.
> 
> Aparently there is a code path where whatever is existing in the
> SKB ip options block matters, and needs to be maintained.
> 
> Someone needs to audit all of this and figure out how to fix the
> problem properly.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I suspect tuntap is part of the problem. The skb may not be
allocated with enough padding or something like that. No guarantees
but will do some investigation.


-- 
