From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] bpf: Add strict alignment flag for BPF_PROG_LOAD.
Date: Thu, 11 May 2017 10:53:11 -0400 (EDT)
Message-ID: <20170511.105311.1695831326048998410.davem@davemloft.net>
References: <20170510.150951.1359250469075249855.davem@davemloft.net>
        <59145EE6.3030409@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932613AbdEKOxW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 10:53:22 -0400
In-Reply-To: <59145EE6.3030409@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 11 May 2017 14:53:58 +0200

> On 05/10/2017 09:09 PM, David Miller wrote:
>> @@ -3574,6 +3581,10 @@ int bpf_check(struct bpf_prog **prog, union
>> bpf_attr *attr)
>>   	} else {
>>   		log_level = 0;
>>   	}
>> +	if (attr->prog_flags & BPF_F_STRICT_ALIGNMENT)
>> +		strict_alignment = true;
>> +	else
>> +		strict_alignment = false;
> 
> Just minor nit: Can we move this into struct bpf_verifier_env
> here instead of global var? The only change it would need is
> in check_ptr_alignment() to pass the env from check_mem_access().
> check_ptr_alignment() can then infer this from env.

I was just being lazy and doing it the way bpf_log is done. :-)

I've moved it into bpf_verifier_env, no problem.

> Rest looks good:
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks again for review.
