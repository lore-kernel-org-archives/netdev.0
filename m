From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/4] Improve bpf ELF-loader under samples/bpf
Date: Tue, 02 May 2017 23:10:04 +0200
Message-ID: <5908F5AC.6000703@iogearbox.net>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34039 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdEBVKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 17:10:09 -0400
In-Reply-To: <149372826543.22268.3617359219409721129.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2017 02:31 PM, Jesper Dangaard Brouer wrote:
> This series improves and fixes bpf ELF loader and programs under
> samples/bpf.  The bpf_load.c created some hard to debug issues when
> the struct (bpf_map_def) used in the ELF maps section format changed
> in commit fb30d4b71214 ("bpf: Add tests for map-in-map").
>
> This was hotfixed in commit 409526bea3c3 ("samples/bpf: bpf_load.c
> detect and abort if ELF maps section size is wrong") by detecting the
> issue and aborting the program.
>
> In most situations the bpf-loader should be able to handle these kind
> of changes to the struct size.  This patch series aim to do proper
> backward and forward compabilility handling when loading ELF files.
>
> This series also adjust the callback that was introduced in commit
> 9fd63d05f3e8 ("bpf: Allow bpf sample programs (*_user.c) to change
> bpf_map_def") to use the new bpf_map_data structure, before more users
> start to use this callback.
>
> Hoping these changes can make the merge window, as above mentioned
> commits have not been merged yet, and it would be good to avoid users
> hitting these issues.

Overall, set looks good to me. The last patch doesn't have a
user yet, so probably better to drop it until there is an actual
user in the tree.

Long term, I'd like to see the samples being migrated to use the
tools/lib/bpf/ library from the tree, so that we can avoid duplicating
effort with having two libs in the tree (f.e. elf map validation is
performed to a certain degree in the other one, but w/o compat
support last time I looked).

Anyway, other than that:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
