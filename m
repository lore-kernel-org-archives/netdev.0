From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Userspace network stack and netchannels.
Date: Wed, 26 Sep 2007 12:47:55 +0400
Message-ID: <20070926084752.GA13187@2ka.mipt.ru>
References: <20070925180043.GA16698@2ka.mipt.ru> <20070925123444.10346e99@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47202 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbXIZIsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 04:48:06 -0400
Content-Disposition: inline
In-Reply-To: <20070925123444.10346e99@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 25, 2007 at 12:34:44PM -0700, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> > It was proven [3] that unetstack can be *much* faster than vanilla TCP
> > stack (mainly because of heavily reduced number of syscalls, different
> > congestion control algorithm and other features).
> 
> I am glad to see a more complete implementation for comparison, but
> by changing several variables at once it makes it hard to evaluate whether
> the improvement comes from user space TCP or the other changes.

Number of issues were improved - mostly reduced number of syscalls (if
size of the message increases results become essentially the same).
Different (non-rfc-compliant) congestion control algorithm allows faster
start and recovery, but in slower links (or longer rtt) it can be wrong.
Originally it was created to show superiority of the netchannel architecture,
but several hundreds of percents in some cases is not result of
peer-to-peer and process context processing. This stack works with
netchannels, which just became a link between hardware and user, such
approach allows huge variety of usage for different network hardware
including safe offloading, sniffing and so on. This stack is an example.

-- 
	Evgeniy Polyakov
