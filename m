From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Wed, 23 Sep 2015 09:31:19 -0700
Message-ID: <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5726932.6r4XOZ2Km2@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Patrick Schaaf <kernelorg@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35861 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbbIWQbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:31:21 -0400
In-Reply-To: <5726932.6r4XOZ2Km2@rofl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-23 at 10:25 +0200, Patrick Schaaf wrote:
> Dear kernel developers,
> 
> I recently started to upgrade my production hosts and VMs from the 3.14 series 
> to 4.1 kernels, starting with 4.1.6. Yesterday, for the second time after I 
> started these upgrades, I experienced one of our webserver VMs hanging.
> 
> The first time this happened, the VM hung completely, all 5 virtual cores 
> spinning at 100%, ping still worked, but nothing else, including no virsh 
> console reaction - I had to destroy and restart that VM. No messages were to 
> be found.
> 
> Yesterday, when it happened the second time, I found the VM spinning on a 
> single core only, and could still connect to it via ssh - but it stopped 
> accepting apache connections. The core it spun on showed 100% time used in 
> "si", with top, and it produced the messages appended below. The VM did not 
> shutdown properly when told to, and had to be destroyed again.
> 
> If I read that dmesg output correctly it spins in __inet_lookup_established, 
> which indeed reads like it has infinite spin potential. But that code itself 
> did not change relative to the 3.14 series we've been running for a long time 
> without the issues - so the root cause would be something else.
> 
> For our production systems I'll revert to the 3.14 series, but maybe this 
> report may help somebody understand what's going on.
> 
> best regards
>   Patrick


You could try following commits :

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=29c6852602e259d2c1882f320b29d5c3fec0de04
