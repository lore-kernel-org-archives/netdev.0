From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: let bpf_tell_extensions return
 SKF_AD_MAX
Date: Tue, 21 Jan 2014 18:55:56 -0800 (PST)
Message-ID: <20140121.185556.583331457644438783.davem@davemloft.net>
References: <1390259977-28770-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msekleta@redhat.com, edumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbaAVCz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 21:55:57 -0500
In-Reply-To: <1390259977-28770-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 21 Jan 2014 00:19:37 +0100

> Michal Sekletar added in commit ea02f9411d9f ("net: introduce
> SO_BPF_EXTENSIONS") a facility where user space can enquire
> the BPF ancillary instruction set, which is imho a step into
> the right direction for letting user space high-level to BPF
> optimizers make an informed decision for possibly using these
> extensions.
> 
> The original rationale was to return through a getsockopt(2)
> a bitfield of which instructions are supported and which
> are not, as of right now, we just return 0 to indicate a
> base support for SKF_AD_PROTOCOL up to SKF_AD_PAY_OFFSET.
> Limitations of this approach are that this API which we need
> to maintain for a long time can only support a maximum of 32
> extensions, and needs to be additionally maintained/updated
> when each new extension that comes in.
> 
> I thought about this a bit more and what we can do here to
> overcome this is to just return SKF_AD_MAX. Since we never
> remove any extension since we cannot break user space and
> always linearly increase SKF_AD_MAX on each newly added
> extension, user space can make a decision on what extensions
> are supported in the whole set of extensions and which aren't,
> by just checking which of them from the whole set have an
> offset < SKF_AD_MAX of the underlying kernel.
> 
> Since SKF_AD_MAX must be updated each time we add new ones,
> we don't need to introduce an additional enum and got
> maintenance for free. At some point in time when
> SO_BPF_EXTENSIONS becomes ubiquitous for most kernels, then
> an application can simply make use of this and easily be run
> on newer or older underlying kernels without needing to be
> recompiled, of course. Since that is for 3.14, it's not too
> late to do this change.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Completely agreed, applied, thanks Daniel.
