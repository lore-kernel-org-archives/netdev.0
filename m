From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 04 Aug 2009 14:02:11 -0700
Message-ID: <878whzl2cs.fsf@caffeine.danplanet.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com>
	<1249331463-11887-6-git-send-email-danms@us.ibm.com>
	<20090804205241.GF10275@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:39844 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754725AbZHDVCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 17:02:13 -0400
In-Reply-To: <20090804205241.GF10275@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 4 Aug 2009 15\:52\:41 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> Does this re-use of tmp make sense?  (It only would if
SH> dev_alloc_skb() did a generic prealloc for any subsequent
SH> skb_clone() which i don't think is the case)

No, this is cruft.

SH> Also, do you need any kind of lock on the queue to make this walk
SH> safe, or do ensure below (sorry i'm slow and haven't gotten there)
SH> that all tasks with an open fd for either end of this sock are
SH> frozen?

Hmm, it seems that holding the lock while processing the queue isn't
really the way to go.  Perhaps comparing the pid of the other end of
the socket against the list in the context is best?

SH> what about UNIXCB(skb).creds and .secid?

Yep, okay.

SH> It looks like the above provides a way around needing
SH> CAP_NET_ADMIN to set SOCK_DBG in sock->sk_flags?  You can probably
SH> fix that by masking it out here, and if a flag in the checkpoint
SH> image says it was on originally, then set it below through
SH> setsockopt.

Yep, okay.

SH> Sanity checking on sk_type, sk_state, backlog etc should probably
SH> also be added.

I check type and state on restart globally and per-protocol.  Backlog
could use it though too, yeah.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
