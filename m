From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
 not interacting well with multicast in 2.6.38-4
Date: Thu, 12 May 2011 16:43:22 -0700
Message-ID: <20110512164322.45626683@nehalam>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
	<1304995124.4065.157.camel@localhost>
	<20110510043833.GG6397@morgul.net>
	<1305031369.4065.259.camel@localhost>
	<20110510180540.GI6397@morgul.net>
	<20110510151100.52a9f8fa@nehalam>
	<20110510233540.GJ6397@morgul.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>, 625914@bugs.debian.org,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Noah Meyerhans <noahm@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39606 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757882Ab1ELXnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 19:43:25 -0400
In-Reply-To: <20110510233540.GJ6397@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011 16:35:40 -0700
Noah Meyerhans <noahm@debian.org> wrote:

> On Tue, May 10, 2011 at 03:11:00PM -0700, Stephen Hemminger wrote:
> > There were two more follow on commits in stable related to this.
> > I recommend merging 2.6.38.6 which includes these.
> 
> The problem still exists in the current 2.6.38.6.  Backing out 5f1c356a
> still solves the problem there.
> 
> I have not yet tried anything outside the stable-2.6.38.y tree, but it
> seems like these same changes are present there, and it's unlikely that
> other releases will work any better.

Does this fix the problem?  The tap driver allocates an skb and throws
it into the receive path, but the skb does not have the same padding
as normal skb's received.

--- a/drivers/net/tun.c	2011-05-12 16:36:15.231347935 -0700
+++ b/drivers/net/tun.c	2011-05-12 16:36:38.503464573 -0700
@@ -614,7 +614,7 @@ static __inline__ ssize_t tun_get_user(s
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
-		align = NET_IP_ALIGN;
+		align = NET_IP_ALIGN + NET_SKB_PAD;
 		if (unlikely(len < ETH_HLEN ||
 			     (gso.hdr_len && gso.hdr_len < ETH_HLEN)))
 			return -EINVAL;

-- 
