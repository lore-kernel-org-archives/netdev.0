From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 20:55:53 +0200
Message-ID: <20151006205553.6975a147@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151006174205.799ac484@griffin>
	<CALnjE+qSdDnmbbHV0O6Pa9z=T=8jFSL2bw5k_m_DwgtchZaCOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785AbbJFSz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 14:55:56 -0400
In-Reply-To: <CALnjE+qSdDnmbbHV0O6Pa9z=T=8jFSL2bw5k_m_DwgtchZaCOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Oct 2015 11:26:31 -0700, Pravin Shelar wrote:
> I do not see need to drop and reallocate dst in this operation. I just
> need to set source IP address and source and dst port in the metadata
> dst already set in skb.

If I'm looking at the code correctly, metadata_dst is stored in the
action and each skb gets only a reference to it. Modifying it would
modify the shared metadata_dst (see execute_set_action).

> This fill_metadata function is not called for every packet so
> ndo_start_xmit() still needs to do route lookup.

Yes. I meant that in those cases where the fill_metadata function was
called, we may skip the lookup. Just an optimization and not an
important one. I'm not even sure it can currently happen as the skb is
cloned for each action.

> egress_tun_info in dp_upcall_info is required to check for failure. It
> would be only set on successful fill_metadata operation.

Or you can just set dst to NULL on failure.

 Jiri

-- 
Jiri Benc
