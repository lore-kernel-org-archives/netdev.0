From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, inode: add support for symlinks and fix
 mtime/ctime
Date: Mon, 31 Oct 2016 15:28:55 -0400 (EDT)
Message-ID: <20161031.152855.2106913677135460954.davem@davemloft.net>
References: <f94e5717c5c494ac054365dee59bf71624702a4a.1477700084.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, tgraf@suug.ch
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945848AbcJaT25 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:28:57 -0400
In-Reply-To: <f94e5717c5c494ac054365dee59bf71624702a4a.1477700084.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 29 Oct 2016 02:30:46 +0200

> While commit bb35a6ef7da4 ("bpf, inode: allow for rename and link ops")
> added support for hard links that can be used for prog and map nodes,
> this work adds simple symlink support, which can be used f.e. for
> directories also when unpriviledged and works with cmdline tooling that
> understands S_IFLNK anyway. Since the switch in e27f4a942a0e ("bpf: Use
> mount_nodev not mount_ns to mount the bpf filesystem"), there can be
> various mount instances with mount_nodev() and thus hierarchy can be
> flattened to facilitate object sharing. Thus, we can keep bpf tooling
> also working by repointing paths.
> 
> Most of the functionality can be used from vfs library operations. The
> symlink is stored in the inode itself, that is in i_link, which is
> sufficient in our case as opposed to storing it in the page cache.
> While at it, I noticed that bpf_mkdir() and bpf_mkobj() don't update
> the directories mtime and ctime, so add a common helper for it called
> bpf_dentry_finalize() that takes care of it for all cases now.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
