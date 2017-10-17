From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] bpf: devmap: Check attr->max_entries more carefully
Date: Mon, 16 Oct 2017 21:30:38 -0700
Message-ID: <0b5e4a49-3738-5b57-1abf-1912b2afff2c@gmail.com>
References: <20171015220020.8157-1-richard@nod.at>
 <100542240.i6NpMmsy5C@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        sp3485@columbia.edu
To: Richard Weinberger <richard@nod.at>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <100542240.i6NpMmsy5C@blindfold>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2017 03:13 PM, Richard Weinberger wrote:
> Am Montag, 16. Oktober 2017, 00:00:20 CEST schrieb Richard Weinberger:
>> max_entries is user controlled and used as input for __alloc_percpu().
>> This function expects that the allocation size is a power of two and
>> less than PCPU_MIN_UNIT_SIZE.
>> Otherwise a WARN() is triggered.
> 
> On a second though, I think we should also have a hard limit for ->max_entries 
> or check for an overflow here:
> 

Or just,

static u64 dev_map_bitmap_size(const union bpf_attr *attr)
{
	return BITS_TO_LONGS((u64) attr->max_entries) *
		sizeof(unsigned long);
}

Let me know if you want me to send a patch or if you want to.

Thanks,
John

> static u64 dev_map_bitmap_size(const union bpf_attr *attr)
> {
>         return BITS_TO_LONGS(attr->max_entries) * sizeof(unsigned long);
> }
> 
> Thanks,
> //richard
> 
