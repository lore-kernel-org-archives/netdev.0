From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] filter: add bpf_optimize_div()
Date: Fri, 21 Nov 2014 09:46:06 +0400
Message-ID: <CAOJe8K2u3UMwx-oaF6qRHOxgYQtHdvZHG6cxo3JRyVj4TWyRyg@mail.gmail.com>
References: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
	<546E5DE9.3050602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35285 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbaKUFqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 00:46:08 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so4123564pab.34
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 21:46:06 -0800 (PST)
In-Reply-To: <546E5DE9.3050602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/14, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 11/20/2014 08:42 PM, Denis Kirjanov wrote:
>> optimize_div() found in  mips bpf jit is really usefull
>> for other arches. So let's put it in filter.h
>>
>> CC: Alexei Starovoitov <ast@plumgrid.com>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>
> NAK
>
> 1) There's no user of this function (you name MIPS JIT, but
>     don't remove it from there) ...

Right, I wanted to get some feedback before removing/adding it to the
other places.

>
> 2) It's not really specific or tied to the BPF API in particular,
>     so doesn't really belong here, rather some more generic kernel
>     header, iff anything.

I was thinking about the best place to put this helper since this
looks more or less generic...
Actually I had to put the RFC tag to the patch

>
>> ---
>>   include/linux/filter.h | 11 +++++++++++
>>   1 file changed, 11 insertions(+)
>>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index ca95abd..b385637 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -414,6 +414,17 @@ static inline void bpf_jit_dump(unsigned int flen,
>> unsigned int proglen,
>>   		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
>>   			       16, 1, image, proglen, false);
>>   }
>> +
>> +static inline int bpf_optimize_div(u32 *k)
>> +{
>> +	/* power of 2 divides can be implemented with right shift */
>> +	if (!(*k & (*k-1))) {
>> +		*k = ilog2(*k);
>> +		return 1;
>> +	}
>> +
>> +	return 0;
>> +}
>>   #else
>>   static inline void bpf_jit_compile(struct bpf_prog *fp)
>>   {
>>
>
