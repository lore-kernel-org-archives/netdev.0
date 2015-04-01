From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Wed, 01 Apr 2015 10:48:31 +0200
Message-ID: <551BB0DF.2050600@iogearbox.net>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net> <551B7F41.3080203@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, tgraf@suug.ch, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Alexei Starovoitov <ast@plumgrid.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51513 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbbDAIsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 04:48:42 -0400
In-Reply-To: <551B7F41.3080203@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2015 07:16 AM, Alexei Starovoitov wrote:
> On 3/30/15 3:35 PM, Daniel Borkmann wrote:
>> +static inline void act_update_drop_map(void)
>> +{
>> +    uint32_t *count, cpu = get_smp_processor_id();
>> +
>> +    count = bpf_map_lookup_elem(&map_drops, &cpu);
>> +    if (count)
>> +        __sync_fetch_and_add(count, 1);
>
> since this function demonstrates poor man's per-cpu counters we can use
> regular *count++ instead of atomic.
> Just picking nits :)

Okay, that's fine.

[...]
>> +/* tc ELF map ABI */
>> +struct bpf_elf_map {
>> +    uint32_t type;
>> +    uint32_t id;
>> +    uint32_t size_key;
>> +    uint32_t size_value;
>> +    uint32_t max_elem;
>> +};
>
> can you change 'id' being last, so that TC+bpf programs from
> samples/bpf/ that don't have 'id' concept can also be loaded?

Will do.

>> +#ifndef min
>> +# define min(x, y) ({            \
>> +    typeof(x) _min1 = (x);        \
>> +    typeof(y) _min2 = (y);        \
>> +    (void) (&_min1 == &_min2);    \
>> +    _min1 < _min2 ? _min1 : _min2; })
>> +#endif
> ...
>> +#ifndef min
>> +# define min(x, y) ({            \
>> +    typeof(x) _min1 = (x);        \
>> +    typeof(y) _min2 = (y);        \
>> +    (void) (&_min1 == &_min2);    \
>> +    _min1 < _min2 ? _min1 : _min2; })
>> +#endif
>
> two 'min' macros in different files?

Yes, I actually wanted to have a stand alone C file, but okay,
I can see to include from utils.h.

>> -static inline int bpf_open_object(const char *path, enum bpf_prog_type type)
>> +static inline int bpf_open_object(const char *path, enum bpf_prog_type type,
>> +                  const char *sec)
>>   {
>>       errno = ENOSYS;
>>       return -1;
>>   }
>
> while playing with it, I hit the ENOSYS first, since my user space
> is quite old. Can you add a human readable printf message here and other
> places, so we don't have to recompile tc with -g and run gdb on it?
> I think it will help distributions to configure dependencies of iproute2
> as well.

Will do and respin.

> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Great work! Thanks a lot!

Thanks, Alexei!
