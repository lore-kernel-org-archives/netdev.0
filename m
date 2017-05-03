From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 0/4] Improve bpf ELF-loader under samples/bpf
Date: Wed, 3 May 2017 08:16:21 +0200
Message-ID: <20170503081621.41a141d0@redhat.com>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
        <5908F5AC.6000703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57336 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751461AbdECGQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 02:16:28 -0400
In-Reply-To: <5908F5AC.6000703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 May 2017 23:10:04 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/02/2017 02:31 PM, Jesper Dangaard Brouer wrote:
> > This series improves and fixes bpf ELF loader and programs under
> > samples/bpf.  The bpf_load.c created some hard to debug issues when
> > the struct (bpf_map_def) used in the ELF maps section format changed
> > in commit fb30d4b71214 ("bpf: Add tests for map-in-map").
> >
> > This was hotfixed in commit 409526bea3c3 ("samples/bpf: bpf_load.c
> > detect and abort if ELF maps section size is wrong") by detecting the
> > issue and aborting the program.
> >
> > In most situations the bpf-loader should be able to handle these kind
> > of changes to the struct size.  This patch series aim to do proper
> > backward and forward compabilility handling when loading ELF files.
> >
> > This series also adjust the callback that was introduced in commit
> > 9fd63d05f3e8 ("bpf: Allow bpf sample programs (*_user.c) to change
> > bpf_map_def") to use the new bpf_map_data structure, before more users
> > start to use this callback.
> >
> > Hoping these changes can make the merge window, as above mentioned
> > commits have not been merged yet, and it would be good to avoid users
> > hitting these issues.  
> 
> Overall, set looks good to me. The last patch doesn't have a
> user yet, so probably better to drop it until there is an actual
> user in the tree.

The reason for simply exporting map_data[] was that in patch 3, the
data-struct (bpf_map_data) is already exposed, thus users can already
grab and store those into a separate data structure.  Thus, it seemed
natural to simply export/expose the map_data[] array directly.  Guess,
I could have combined patch 4 and 3.  As patch-3 uses the data struct,
but in an indirect way.

To Daniel, if you still feel we should drop patch 4, then let me know.
It is only the other patches that are time critical, as patch 4 is
trivial to introduce once the first sample program uses this directly
(instead of indirectly through the callback).


> Long term, I'd like to see the samples being migrated to use the
> tools/lib/bpf/ library from the tree, so that we can avoid duplicating
> effort with having two libs in the tree (f.e. elf map validation is
> performed to a certain degree in the other one, but w/o compat
> support last time I looked).

Yes, I agree that we should migrate to use the tools/lib/bpf/ library.
But as you also say, it actually have similar compat loader issues,
although it does more validation.  Once we start this migration, I'll
also fix the compat loader issues in this lib.
 
> Anyway, other than that:
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
