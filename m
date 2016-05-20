From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] bpf: Use mount_nodev not mount_ns to mount the bpf
 filesystem
Date: Sat, 21 May 2016 01:27:42 +0200
Message-ID: <4f11914a-f5cc-3df4-5b9d-0946f9f31ec2@stressinduktion.org>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>
 <79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
 <87inybv2hv.fsf@x220.int.ebiederm.org> <573CD3D8.3030308@iogearbox.net>
 <bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
 <874m9sfjyf.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52193 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751196AbcETX1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:27:47 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 0785920AC2
	for <netdev@vger.kernel.org>; Fri, 20 May 2016 19:27:46 -0400 (EDT)
In-Reply-To: <874m9sfjyf.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.05.2016 00:22, Eric W. Biederman wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks Eric!
