From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 net-next 3/8] bpf: Add BPF_ macros
Date: Mon, 12 Dec 2016 12:48:52 +0100
Message-ID: <584E8EA4.4030200@iogearbox.net>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com> <1481503995-24825-4-git-send-email-dsa@cumulusnetworks.com> <88e7eece-be2a-3b11-3dc1-3afa7a9bb14a@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41342 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbcLLLs4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 06:48:56 -0500
In-Reply-To: <88e7eece-be2a-3b11-3dc1-3afa7a9bb14a@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2016 12:28 PM, Hannes Frederic Sowa wrote:
> On 12.12.2016 01:53, David Ahern wrote:
>> Based on version in kernel repo, samples/bpf/libbpf.h
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>   include/bpf_util.h | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 179 insertions(+)
>>
>> diff --git a/include/bpf_util.h b/include/bpf_util.h
>> index 726e34777755..5361dab1933d 100644
>
> Maybe this was already discussed: why are those not part of uapi? They
> get used in the bpf manpage.

The reason why these macros haven't been exposed to uapi header was because
they are not strict part of kernel abi. So really only the very minimum that
had to go there (such as insn opcodes) were placed into the header. That way,
kernel is still free to, for example, change or rename the macros once new
insns would get added, and user space can just define what it really needs.
That way, both don't get into each others way long term. Often it's also not
really needed if you have an elf loader, f.e. iproute2 could live without
them (up to this point).

Just took a look at the man page example, we don't even define BPF_CALL_FUNC()
in the kernel, so it's also not exactly the same. Probably makes sense to
fix/complete that example and in general add a description there wrt opcodes.
Last time I spoke with Michael, he planned to make a bigger revision to the
man page to improve documentation.

Thanks,
Daniel
