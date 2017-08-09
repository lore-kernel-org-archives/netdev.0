From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/9] bpf: add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed, 09 Aug 2017 22:32:34 +0200
Message-ID: <598B7162.90509@iogearbox.net>
References: <63b41a38e0d58536700c999ade7c2c267bd2613d.1502272924.git.daniel@iogearbox.net>        <20170809.095553.268665355274669790.davem@davemloft.net>        <598B3FCA.7060904@iogearbox.net> <20170809.110128.709552645127117641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43629 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbdHIUcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 16:32:42 -0400
In-Reply-To: <20170809.110128.709552645127117641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2017 08:01 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Wed, 09 Aug 2017 19:00:58 +0200
>
>> On 08/09/2017 06:55 PM, David Miller wrote:
>>> From: Daniel Borkmann <daniel@iogearbox.net>
>>> Date: Wed,  9 Aug 2017 12:23:53 +0200
>>>
>>>>     [1] https://github.com/borkmann/llvm/tree/bpf-insns
>>>
>>> How is this "backwards compatible"?
>>>
>>> If someone takes a new LLVM and tries to load those programs
>>> into an older kernel they will be rejected.
>>>
>>> There appears to be no effort to make things work cleanly in
>>> that situation at all.
>>
>> No, that was just the patch I used for LLVM to enable the
>> insns, so not the final one that will be submitted there
>> officially where we have a switch to enable/disable this
>> functionality.
>
> So how does this switch work and how are people expected to use this
> switch?  What is the default value and is it ever expected to change
> in the future?
>
> Yeah this seems hella awesome to get cilium programs smaller and
> faster in a restricted environment where you control the running
> kernel and everything.

For the case of cilium, we are not in control of the kernel, by
the way, we run a few probes that are small BPF insns snippets
that test the kernel for presence of certain features (e.g. helper,
verifier, maps) and enable/disable them accordingly later in the
code generation. On the user space side, we're indeed a bit more
flexible and have no such restriction.

Plan is for LLVM as one of the frontends that generate byte code
(ply, for example, can probe the kernel directly for its code
generation) to have i) a target specific option to offer a
possibility to explicitly enable the extension by the user (as we
have with -m target specific extensions today for various cpu
insns), and ii) have the kernel check for presence of the extensions
and enable it transparently when the user selects more aggressive
options such as -march=native in a bpf target context, so we can
select the underlying features transparently. I should have made
that more clear earlier, sorry about that.

Thanks,
Daniel
