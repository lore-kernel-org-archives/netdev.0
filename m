From: Alexei Starovoitov <ast@fb.com>
Subject: Re: Alignment in BPF verifier
Date: Wed, 24 May 2017 09:39:43 -0700
Message-ID: <7b62dd5f-7cae-3aa7-5022-c1f2add9ee1a@fb.com>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
 <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
 <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
 <20170519.163957.1950740987459934279.davem@davemloft.net>
 <591F7A28.3020004@iogearbox.net>
 <f882c40e-bd50-f08e-afd8-f6396fc24ebc@solarflare.com>
 <ad2162c3-1286-ab35-464a-8d21a1adc94f@fb.com>
 <5924A938.2090808@iogearbox.net>
 <65535d13-ce7e-56b9-807d-bf89d7d91ca9@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50833 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1763936AbdEXQkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 12:40:04 -0400
In-Reply-To: <65535d13-ce7e-56b9-807d-bf89d7d91ca9@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/24/17 6:46 AM, Edward Cree wrote:
> On 23/05/17 22:27, Daniel Borkmann wrote:
>> On 05/23/2017 09:45 PM, Alexei Starovoitov wrote:
>>> On 5/23/17 7:41 AM, Edward Cree wrote:
>>>> Hmm, that means that we can't do arithmetic on a
>>>>  PTR_TO_MAP_VALUE_OR_NULL, we have to convert it to a PTR_TO_MAP_VALUE
>>>>  first by NULL-checking it.  That's probably fine, but I can just about
>>>>  imagine some compiler optimisation reordering them.  Any reason not to
>>>>  split this out into a different reg->field, rather than overloading id?
>>>
>>> 'id' is sort of like 'version' of a pointer and has the same meaning in
>>> both cases. How exactly do you see this split?
> I was thinking there would be reg->id and reg->map_id.  Both could share the
>  env->id_gen, since that's not likely to run out, but they'd be separate
>  fields so that a PTR_TO_MAP_VALUE_OR_NULL could say "this is either map_value
>  plus a 4-byte-aligned offset less than 24, or NULL plus that same offset",
>  and then if another pointer with the same map_id and no variable-offset part
>  was NULL-checked, we could convert both pointers to PTR_TO_MAP_VALUE.  (I'm
>  getting rid of PTR_TO_MAP_VALUE_ADJ in my patch, along with several other
>  types, by taking the 'we have an offset' part out of the bpf_reg_type.)

got it. makes sense.

>> So far we haven't run into this kind of optimization
>> from llvm side yet[...] Out of curiosity, did you run into it with llvm?
> No, purely theoretical.  I haven't even built/installed llvm yet, I'm just
>  working with the bytecode in test_verifier.c for now.  I'm merely trying to
>  not have restrictions that are unnecessary; but since allowing this kind of
>  construct would take a non-zero amount of work, I'll file it for later.

modern fedora/ubuntu come with llvm that has bpf backend by default.
