From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: iproute2: potential upgrade regression with 58a3e827
Date: Fri, 08 Nov 2013 14:42:20 -0800
Message-ID: <87wqkiy0qb.fsf@xmission.com>
References: <527D2768.1030403@canonical.com> <87k3gi4lub.fsf@xmission.com>
	<527D65FB.8000407@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42356 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758023Ab3KHWmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 17:42:32 -0500
In-Reply-To: <527D65FB.8000407@canonical.com> (Chris J. Arges's message of
	"Fri, 08 Nov 2013 16:30:19 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris J Arges <chris.j.arges@canonical.com> writes:

> Fair enough. I really wanted to get a feel if this seemed like an actual
> bug, or rather it's behaving like we'd expect. I don't mind writing
> code, but I want to know if I'm hunting a bug, or adding a feature.

Making it ip netns add work reliably inside of ip netns exec and
handling all of the permutations is adding a feature.

Understanding why ip netns exec is failing in your specific case sounds
like there may be a missing error message.  Clearly you get into a
context where /var/run/netns/netns_old is no the bind mount we would
expect it to be.

I saw nothing that should unmake /var/run/netns/nnetns_old  as a mount
point.  So something strange is going on.

So you might want to go through and inspect to see what is happening.
Perhaps there is a missing error message somewhere.

Without understanding why that mountpoint fails to exist I can't say if
it is a real bug or if it just something weird caused by using an ip
netns exec it was not designed to be used and is known not to be 100%
robust in.

Eric
