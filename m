From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map implementation
Date: Thu, 05 Jan 2017 21:01:43 +0100
Message-ID: <586EA627.6020404@iogearbox.net>
References: <20161229172855.14910-1-daniel@zonque.org> <20161229172855.14910-2-daniel@zonque.org> <586E7366.1010708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55100 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754714AbdAEUBs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:01:48 -0500
In-Reply-To: <586E7366.1010708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2017 05:25 PM, Daniel Borkmann wrote:
> On 12/29/2016 06:28 PM, Daniel Mack wrote:
>> This trie implements a longest prefix match algorithm that can be used
>> to match IP addresses to a stored set of ranges.
>>
>> Internally, data is stored in an unbalanced trie of nodes that has a
>> maximum height of n, where n is the prefixlen the trie was created
>> with.
>>
>> Tries may be created with prefix lengths that are multiples of 8, in
>> the range from 8 to 2048. The key used for lookup and update operations
>> is a struct bpf_lpm_trie_key, and the value is a uint64_t.
>>
>> The code carries more information about the internal implementation.
>>
>> Signed-off-by: Daniel Mack <daniel@zonque.org>
>> Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
>
> Thanks for working on it, and sorry for late reply. In addition to
> Alexei's earlier comments on the cover letter, a few comments inline:
>
[...]
>> +static struct bpf_map *trie_alloc(union bpf_attr *attr)
>> +{
>> +    struct lpm_trie *trie;
>> +
>> +    /* check sanity of attributes */
>> +    if (attr->max_entries == 0 || attr->map_flags ||
>> +        attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
>> +        attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
>> +        attr->value_size != sizeof(u64))
>> +        return ERR_PTR(-EINVAL);

One more question on this regarding value size as u64 (perhaps I
missed it along the way): reason this was chosen was because for
keeping stats? Why not making user choose a size as in other maps,
so also custom structs could be stored there?

Thanks,
Daniel
