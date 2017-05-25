From: David Miller <davem@davemloft.net>
Subject: Re: Alignment in BPF verifier
Date: Thu, 25 May 2017 12:31:58 -0400 (EDT)
Message-ID: <20170525.123158.1379700931139186123.davem@davemloft.net>
References: <f882c40e-bd50-f08e-afd8-f6396fc24ebc@solarflare.com>
        <ad2162c3-1286-ab35-464a-8d21a1adc94f@fb.com>
        <5924A938.2090808@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, ecree@solarflare.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761171AbdEYQcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:32:00 -0400
In-Reply-To: <5924A938.2090808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 23 May 2017 23:27:20 +0200

> On 05/23/2017 09:45 PM, Alexei Starovoitov wrote:
>> On 5/23/17 7:41 AM, Edward Cree wrote:
>>> Hmm, that means that we can't do arithmetic on a
>>>  PTR_TO_MAP_VALUE_OR_NULL, we have to convert it to a PTR_TO_MAP_VALUE
>>>  first by NULL-checking it.  That's probably fine, but I can just about
>>>  imagine some compiler optimisation reordering them.  Any reason not to
>>>  split this out into a different reg->field, rather than overloading
>>>  id?
>>
>> 'id' is sort of like 'version' of a pointer and has the same meaning
>> in
>> both cases. How exactly do you see this split?
> 
> Also, same id is never reused once generated and later propagated
> through regs. So far we haven't run into this kind of optimization
> from llvm side yet, but others which led to requiring the id marker
> (see 57a09bf0a416). I could imagine it might be needed at some point,
> though where we later transition directly to PTR_TO_MAP_VALUE_ADJ
> after NULL check. Out of curiosity, did you run into it with llvm?

We could handle this issue in find_good_pkt_pointers(), nothing prevents
us from advancing state there for cases like Edward notes above.
