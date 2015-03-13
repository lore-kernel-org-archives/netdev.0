From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] ebpf: add prandom helper for packet sampling
Date: Fri, 13 Mar 2015 18:03:28 +0100
Message-ID: <55031860.20903@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net> <83348b7717b2f044140539fc7faa36bebcc3da58.1426249641.git.daniel@iogearbox.net> <55031730.5030303@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48806 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043AbbCMRDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 13:03:33 -0400
In-Reply-To: <55031730.5030303@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2015 05:58 PM, Alexei Starovoitov wrote:
> On 3/13/15 6:22 AM, Daniel Borkmann wrote:
>>
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index 3fa1af8..4efc41f 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -165,6 +165,7 @@ enum bpf_func_id {
>>       BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
>>       BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
>>       BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
>> +    BPF_FUNC_random,      /* prandom() as u32 or u64 */
>
> can you rename it to BPF_FUNC_get_random_value ?
> I'd like names to be as descriptive as possible.

Ok, sure.

> User space can pick any name it likes anyway:
> static u64 (*my_foo_func)() = (void *) BPF_FUNC_get_random_value;
>
> Also it will make the following less obscure:
>  > +extern const struct bpf_func_proto bpf_random_proto;
>
> 'bpf_get_random_value_proto' looks better then 'bpf_random_proto' ;)
>
>> +static u64 bpf_random(u64 dw, u64 r2, u64 r3, u64 r4, u64 r5)
>> +{
>> +    return prandom_u32() | (dw ? ((u64)prandom_u32() << 32) : 0);
>
> can you make first argument to be a flag instead of bool ?
> 0 to return u32, 1 to return u64 and >=2 to be reserved and
> return -EINVAL?
> This way we can extend it later. For example 2 might return
> 8 truly random bytes from get_random_bytes_arch()

Yes, that's better.

>> +const struct bpf_func_proto bpf_random_proto = {
>> +    .func        = bpf_random,
>> +    .gpl_only    = false,
>
> non-gpl allowed?
> well I guess prandom_u32() is non-gpl either.

It can be used by anyone, yes. If there are strong opinions to make
this GPL-only, I don't mind, but I think it might be exaggerated.

Will respin.

Thanks,
Daniel
