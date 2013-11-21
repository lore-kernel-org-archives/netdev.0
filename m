From: David Miller <davem@davemloft.net>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Thu, 21 Nov 2013 13:03:39 -0500 (EST)
Message-ID: <20131121.130339.204009506339126583.davem@davemloft.net>
References: <CA+mtBx8g9uYOc0euQiEDi8qfx_ZggsE_Wn8N5R+peE1_N4WKEg@mail.gmail.com>
	<20131120.215025.590189385589840672.davem@davemloft.net>
	<CA+mtBx_KuiC2KWXKuV-+KBrJ7GhMK0L5kAH8sO7CA3sQqGp+Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab3KUSDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:03:41 -0500
In-Reply-To: <CA+mtBx_KuiC2KWXKuV-+KBrJ7GhMK0L5kAH8sO7CA3sQqGp+Cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 21 Nov 2013 08:28:18 -0800

> Since we're doing deep inspection now in flow_dissector, we should
> already have the discovered the hash on the inner header if it's a
> standard encap.

For AH and normal IP tunnels, this might be fine.  But this is not
possible for ESP since the inner headers are encrypted when the
flow_dissector takes a look.

And again, there is the issue of which hardware devices are doing this
properly.

And for those that do perform inner-tunnel deep inspection for rxhash
generation, how many layers of tunnels are they able to look beneath?

My impression is that they support one level, at best, which means the
rxhash is basically reliable only under a specific set of conditions.

I need you to elaborate with your knowledge of what hardware actually
supports and does in this area a bit more before I can have a real
opinion on what we should be doing.

Thanks.
