From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Thu, 24 Nov 2011 19:25:39 +0000
Message-ID: <1322162739.2784.26.camel@bwh-desktop>
References: <201111241443.59191.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Tim Hockin <thockin@hockin.org>,
	Olaf Kirch <okir@suse.de>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24877 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474Ab1KXTZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 14:25:44 -0500
In-Reply-To: <201111241443.59191.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-24 at 14:43 +0100, Jean Delvare wrote:
> From: Olaf Kirch <okir@suse.de>
> 
> We had a customer report concerning problems with a Natsemi DP83815-D
> and long cables. With 100m cables, the network would be essentially dead,
> not a single packet would get through either way. We had to apply the
> patch below to make it work.
> 
> The patch adds a module parameter named "no_cable_magic" that does
> two things:
> 
>  -	Unconditionally set the DSPCFG register to the
> 	fixed value. Without this change, the chip apparently
> 	never completes autonegotiation in the tested configuration.
> 
> 	This has been an unconditional assignment for a long time,
> 	until this was changed in 2.6.11 (there's an interesting
> 	explanation in the ChangeLog, subject is
> 	"[PATCH] natsemi long cable fix", bk commit is
> 	5871b81bf2b5cf188deab0d414dce104fcb69ca6, git commit in
> 	tglx/history tree is c0d51c67f9c398279a95c5a7df387f2d9a586c98.
> 
>  -	Skip the bit banging in {,un}do_cable_magic. It seems that
> 	if we write the DSPCFG register as above, a rev D chip will report
> 	all cables as "short cables", which do_cable_magic detects, and
> 	trying to be helpful it will "fix" the attenuation coefficient.
> 
> I admit the use of a module parameter is ugly, but I didn't find a sane
> way to fix this - especially since the magic registers we're changing
> are undocumented.
[...]

This could be implemented as an ethtool 'private flag'.  However, the
ethtool utility currently does not provide an interface to them.
Perhaps you could implement both the private flag and the module
parameter for now, and then drop the module parameter some time after
the utility has been updated.

You would need to:
1. Number the flags starting from 0.  Well, that was easy.
2. Implement {get,set}_priv_flags() operations to access all flags as
   a bitmask.
3. Expose the flag names as string set ETH_SS_PRIV_FLAGS accessed by
   get_sset_count() and get_strings() operations.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
