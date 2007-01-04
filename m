From: "Adam J. Richter" <adam@yggdrasil.com>
Subject: Re: selinux networking: sleeping functin called from invalid context in 2.6.20-rc[12]
Date: Thu, 4 Jan 2007 19:32:11 +0800
Message-ID: <200701041132.l04BWBpD012314@freya.yggdrasil.com>
Cc: akpm@osdl.org, davem@davemloft.net, mingo@elte.hu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.219.161.71] ([221.219.161.71]:34279 "EHLO
	freya.yggdrasil.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S964794AbXADL5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 06:57:52 -0500
To: paul.moore@hp.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Jan 2007 15:46:31 -0500, Paul Moore wrote:
>This makes me believe that Ingo's patch (which I see is now in Linus' and 
>Andrew's trees) is the way to go and not the lock re-order approach in Adam's 
>patch.  I'm going to continue to look into this, almost more for my own 
>education than anything else, but I thought I would mention this lock 
>dependency message as it seemed relevant to the discussion.

	Both Ingo's patch and mine preserved the lock order, in a
sense: take the read_read_lock first, and avoid locking the socket if
possible.  Ingo's patch avoided unlocking and relocking by using some
facilities that I must admit my prior ignorance of.  So, I agree that
if both patches are "correct", then Ingo's is better.

	I have been running Ingo's patch for the past ~1.5 days, and
as far as I can tell it seems to be no worse than mine.

	The reason for such a guarded description as "no worse than
mine" is that I have been experiencing occasoinal system hangs that
started in 2.6.20-rc1 without any patch, which I have observed in
2.6.20-rc3 with my patch, and also 2.6.20-rc3 with Ingo's patch.
These hangs may be completly unrelated to this selinux issue though
and it may be days before get around to studying it more carefully, so
I'm happy to see Ingo's patch integrated now.

Adam
