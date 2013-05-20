From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against spraying
 attacks
Date: Mon, 20 May 2013 11:50:27 +0200
Message-ID: <5199F1E3.1020109@redhat.com>
References: <1368844623.3301.142.camel@edumazet-glaptop> <AE90C24D6B3A694183C094C60CF0A2F6026B723E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B723E@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2013 10:51 AM, David Laight wrote:
>> hpa bringed into my attention some security related issues
>> with BPF JIT on x86.
>>
>> This patch makes sure the bpf generated code is marked read only,
>> as other kernel text sections.
>>
>> It also splits the unused space (we vmalloc() and only use a fraction of
>> the page) in two parts, so that the generated bpf code not starts at a
>> known offset in the page, but a pseudo random one.
> ...
>> +static struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
>> +						  u8 **image_ptr)
> ...
>> +	/* insert a random number of int3 instructions before BPF code */
>> +	*image_ptr = &header->image[prandom_u32() % hole];
>> +	return header;
>> +}
>
> Hmmm.... anyone looking to overwrite kernel code will then start
> looking for blocks of 0xcc bytes and know that what follows
> is the beginning of a function.
> That isn't any harder than random writes.
>
> Copying a random part of .rodata might be better - especially
> if you can find part of .rodata.str*.

Here seems also to be another approach ...

   http://grsecurity.net/~spender/jit_prot.diff

via: http://www.reddit.com/r/netsec/comments/13dzhx/linux_kernel_jit_spray_for_smep_kernexec_bypass/
