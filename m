From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] ebpf, x86: fix general protection fault when tail
 call is invoked
Date: Tue, 28 Jul 2015 19:17:11 +0200
Message-ID: <55B7B917.4090102@iogearbox.net>
References: <23a2630be3c3d41932b9df134f06b9b44671b55e.1438088105.git.daniel@iogearbox.net> <55B7B590.8030600@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59623 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbbG1RRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 13:17:16 -0400
In-Reply-To: <55B7B590.8030600@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2015 07:02 PM, Alexei Starovoitov wrote:
> On 7/28/15 6:26 AM, Daniel Borkmann wrote:
>> After patch, disassembly:
>>
>>    [...]
>>    9e:   lea    0x80(%rsi,%rdx,8),%rax   <--- CONFIG_LOCKDEP/CONFIG_LOCK_STAT
>>          48 8d 84 d6 80 00 00 00
>>    a6:   mov    (%rax),%rax
>>          48 8b 00
>>    [...]
>>
>>    [...]
>>    9e:   lea    0x50(%rsi,%rdx,8),%rax   <--- No CONFIG_LOCKDEP
>>          48 8d 84 d6 50 00 00 00
>>    a6:   mov    (%rax),%rax
>>          48 8b 00
>>    [...]
>>
>> Fixes: b52f00e6a715 ("x86: bpf_jit: implement bpf_tail_call() helper")
>> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
>
> Thanks for fixing it.

No problem!

> Most of my development is actually with LOCKDEP on, but I don't ever
> turn LOCK_STAT on, so sadly missed this 48 byte increase of 80 byte
> structure :(

I feel that at some point we might have hit this anyway, e.g. Huawei
guys with their perf work further extending bpf_maps, etc, etc.

Thanks,
Daniel
