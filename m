From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: Use mount_nodev not mount_ns to mount the bpf
 filesystem
Date: Fri, 20 May 2016 19:46:55 -0400 (EDT)
Message-ID: <20160520.194655.1996549847813859589.davem@davemloft.net>
References: <573CD3D8.3030308@iogearbox.net>
	<bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
	<874m9sfjyf.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, daniel@iogearbox.net, ast@kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbcETXq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:46:57 -0400
In-Reply-To: <874m9sfjyf.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 20 May 2016 17:22:48 -0500

> 
> While reviewing the filesystems that set FS_USERNS_MOUNT I spotted the
> bpf filesystem.  Looking at the code I saw a broken usage of mount_ns
> with current->nsproxy->mnt_ns. As the code does not acquire a
> reference to the mount namespace it can not possibly be correct to
> store the mount namespace on the superblock as it does.
> 
> Replace mount_ns with mount_nodev so that each mount of the bpf
> filesystem returns a distinct instance, and the code is not buggy.
> 
> In discussion with Hannes Frederic Sowa it was reported that the use
> of mount_ns was an attempt to have one bpf instance per mount
> namespace, in an attempt to keep resources that pin resources from
> hiding.  That intent simply does not work, the vfs is not built to
> allow that kind of behavior.  Which means that the bpf filesystem
> really is buggy both semantically and in it's implemenation as it does
> not nor can it implement the original intent.
> 
> This change is userspace visible, but my experience with similar
> filesystems leads me to believe nothing will break with a model of each
> mount of the bpf filesystem is distinct from all others.
> 
> Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied and queued up for -stable, thanks everyone.
