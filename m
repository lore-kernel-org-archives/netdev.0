From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: remove sub-interface mac address policy
Date: Thu, 21 Sep 2006 20:09:39 +0200
Message-ID: <20060921200939.1cab8c1c@logostar.upir.cz>
References: <20060914143321.GA1962@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:25005 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751426AbWIUSJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 14:09:49 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060914143321.GA1962@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 07:33:21 -0700, David Kimdon wrote:
> Wireless vlan interfaces need to have the same mac address as
> other sub interfaces.  Rather than complicate the kernel here by
> adding yet another case where uniqueness is not required, remove
> the check on mac address uniqueness altogether.
> 
> We should not implement a mac address allocation policy here.  It
> is difficult to get it right in all cases and does not belong in
> the kernel.  It is better to leave this to be implemented as a
> userspace policy.

I disagree. This is not about policy, this is about prevention of
accidental violation of IEEE 802.11. The only effect of this patch would
be forcing drivers to do that check themselves thus duplicating code.

Actually, I'd like to add support for the common case (based on a flag in
ieee80211_hw) when WDS is _required_ to have the same MAC address as an AP
interface. That will complicate things even more in the stack but save a
lot of duplicated code in drivers.

I agree that getting this to work with wireless vlans is not easy.
Actually, I'm convinced I broke vlan support at several other places too.
It's really hard not to break it if you know nothing about it.

What is the purpose of "wireless vlans"? Is it something Atheros-specific?
Is it documented somewhere? Or is it in some of IEEE 802.11 standards and I
just overlooked it? (In that case I would be more than happy to review the
whole stack and fix it.) Could you send us some pointers?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
