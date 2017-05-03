From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/4] Improve bpf ELF-loader under samples/bpf
Date: Wed, 03 May 2017 13:48:04 +0200
Message-ID: <5909C374.3050602@iogearbox.net>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>     <5908F5AC.6000703@iogearbox.net> <20170503081621.41a141d0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38366 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751354AbdECLsJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 07:48:09 -0400
In-Reply-To: <20170503081621.41a141d0@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2017 08:16 AM, Jesper Dangaard Brouer wrote:
> On Tue, 02 May 2017 23:10:04 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> On 05/02/2017 02:31 PM, Jesper Dangaard Brouer wrote:
>>> This series improves and fixes bpf ELF loader and programs under
>>> samples/bpf.  The bpf_load.c created some hard to debug issues when
>>> the struct (bpf_map_def) used in the ELF maps section format changed
>>> in commit fb30d4b71214 ("bpf: Add tests for map-in-map").
>>>
>>> This was hotfixed in commit 409526bea3c3 ("samples/bpf: bpf_load.c
>>> detect and abort if ELF maps section size is wrong") by detecting the
>>> issue and aborting the program.
>>>
>>> In most situations the bpf-loader should be able to handle these kind
>>> of changes to the struct size.  This patch series aim to do proper
>>> backward and forward compabilility handling when loading ELF files.
>>>
>>> This series also adjust the callback that was introduced in commit
>>> 9fd63d05f3e8 ("bpf: Allow bpf sample programs (*_user.c) to change
>>> bpf_map_def") to use the new bpf_map_data structure, before more users
>>> start to use this callback.
>>>
>>> Hoping these changes can make the merge window, as above mentioned
>>> commits have not been merged yet, and it would be good to avoid users
>>> hitting these issues.
>>
>> Overall, set looks good to me. The last patch doesn't have a
>> user yet, so probably better to drop it until there is an actual
>> user in the tree.
>
> The reason for simply exporting map_data[] was that in patch 3, the
> data-struct (bpf_map_data) is already exposed, thus users can already
> grab and store those into a separate data structure.  Thus, it seemed
> natural to simply export/expose the map_data[] array directly.  Guess,
> I could have combined patch 4 and 3.  As patch-3 uses the data struct,
> but in an indirect way.
>
> To Daniel, if you still feel we should drop patch 4, then let me know.
> It is only the other patches that are time critical, as patch 4 is
> trivial to introduce once the first sample program uses this directly
> (instead of indirectly through the callback).

Ah, if there's still code coming from your side that will make use
of it, I'm fine with this, though it's usually best to add it with
an actual user. Given it's sample code, I don't mind too much if that
happens at a later point in time.

Thanks,
Daniel
