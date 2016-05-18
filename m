From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC][PATCH net] bpf: Use mount_nodev not mount_ns to mount the
 bpf filesystem
Date: Wed, 18 May 2016 12:48:27 +0200
Message-ID: <79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35263 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752407AbcERKsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 06:48:30 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 82EE621154
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 06:48:29 -0400 (EDT)
In-Reply-To: <87oa84wa6h.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.05.2016 01:12, Eric W. Biederman wrote:
> 
> While reviewing the filesystems that set FS_USERNS_MOUNT I spotted the
> bpf filesystem.  Looking at the code I saw a broken usage of mount_ns
> with current->nsproxy->mnt_ns. As the code does not acquire a reference
> to the mount namespace it can not possibly be correct to store the mount
> namespace on the superblock as it does.
> 
> Replace mount_ns with mount_nodev so that each mount of the bpf
> filesystem returns a distinct instance, and the code is not utterly
> broken.
> 
> Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> 
> No one should care about this change, as userspace typically only mounts
> things once and does not depend on things in one mount do not showing up
> in another.  Can someone who actually uses the bpf filesystem please
> verify this.
> 
> This needs to be fixed as the existing code is broken beyond words that
> I know how to express.

The idea is to have the bpf filesystem as a singeleton per mnt-namespace
to prevent endless instances being created and kernel resources being
hogged by pinning them to hard to discover bpf mounts.

Do you see any problem with adding appropriate reference counts?

Bye,
Hannes
