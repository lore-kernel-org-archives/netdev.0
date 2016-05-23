From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, inode: disallow userns mounts
Date: Mon, 23 May 2016 15:09:01 -0700 (PDT)
Message-ID: <20160523.150901.61113479651269879.davem@davemloft.net>
References: <2e93b4dc22940025ef082970cbab0f499e1e9726.1463950945.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbcEWWJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:09:02 -0400
In-Reply-To: <2e93b4dc22940025ef082970cbab0f499e1e9726.1463950945.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 22 May 2016 23:16:18 +0200

> Follow-up to commit e27f4a942a0e ("bpf: Use mount_nodev not mount_ns
> to mount the bpf filesystem"), which removes the FS_USERNS_MOUNT flag.
> 
> The original idea was to have a per mountns instance instead of a
> single global fs instance, but that didn't work out and we had to
> switch to mount_nodev() model. The intent of that middle ground was
> that we avoid users who don't play nice to create endless instances
> of bpf fs which are difficult to control and discover from an admin
> point of view, but at the same time it would have allowed us to be
> more flexible with regard to namespaces.
> 
> Therefore, since we now did the switch to mount_nodev() as a fix
> where individual instances are created, we also need to remove userns
> mount flag along with it to avoid running into mentioned situation.
> I don't expect any breakage at this early point in time with removing
> the flag and we can revisit this later should the requirement for
> this come up with future users. This and commit e27f4a942a0e have
> been split to facilitate tracking should any of them run into the
> unlikely case of causing a regression.
> 
> Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks.
