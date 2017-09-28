From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] libbpf: use map_flags when creating maps
Date: Thu, 28 Sep 2017 23:44:58 +0200
Message-ID: <59CD6D5A.8080201@iogearbox.net>
References: <20170927140458.44337-1-kraigatgoog@gmail.com> <f7d4addc-9f6a-4ddb-b383-f255cd2f728f@fb.com> <59CC201C.6090502@iogearbox.net> <CAEfhGiwai3fZsWPx--Axyc1n4+WRwxeFO+uLgQKbQ-8wiJqtAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>,
        netdev <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46934 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdI1VpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:45:04 -0400
In-Reply-To: <CAEfhGiwai3fZsWPx--Axyc1n4+WRwxeFO+uLgQKbQ-8wiJqtAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2017 07:33 PM, Craig Gallek wrote:
> On Wed, Sep 27, 2017 at 6:03 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 09/27/2017 06:29 PM, Alexei Starovoitov wrote:
>>> On 9/27/17 7:04 AM, Craig Gallek wrote:
>>>> From: Craig Gallek <kraig@google.com>
[...]
>>>
>>> yes it will break loading of pre-compiled .o
>>> Instead of breaking, let's fix the loader to do it the way
>>> samples/bpf/bpf_load.c does.
>>> See commit 156450d9d964 ("samples/bpf: make bpf_load.c code compatible
>>> with ELF maps section changes")
>>
>> +1, iproute2 loader also does map spec fixup
>>
>> For libbpf it would be good also such that it reduces the diff
>> further between the libbpf and bpf_load so that it allows move
>> to libbpf for samples in future.
>
> Fair enough, I'll try to get this to work more dynamically.  I did
> noticed that the fields of struct bpf_map_def in
> selftests/.../bpf_helpers.h and iproute2's struct bpf_elf_map have
> diverged. The flags field is the only thing missing from libbpf right
> now (and they are at the same offset for both), so it won't be an
> issue for this change, but it is going to make unifying all of these
> things under libbpf not trivial at some point...

Yes, iproute2 uses its own loader with own specifics related to
iproute2. With the above I rather meant that we can reduce the
gap between libbpf and bpf_load from the BPF samples, so that
it would allow us to migrate samples over entirely, there was
unfortunately never a follow-up on 156450d9d964 though, but given
there is need to extend libbpf (I guess mostly due to lpm map
handling ;)), we need to do a similar thing there as well to not
break existing obj files.
