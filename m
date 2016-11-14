From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/3] bpf, mlx5: fix various refcount/prog issues in
 mlx5e_xdp_set
Date: Mon, 14 Nov 2016 09:49:49 +0100
Message-ID: <58297AAD.8060003@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net> <03741f7075af64e83d23add379bdab41204396b0.1479080215.git.daniel@iogearbox.net> <20161114024908.GB94347@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bblanco@plumgrid.com, tariqt@mellanox.com,
        zhiyisun@gmail.com, ranas@mellanox.com, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36674 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbcKNIt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 03:49:56 -0500
In-Reply-To: <20161114024908.GB94347@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 03:49 AM, Alexei Starovoitov wrote:
> On Mon, Nov 14, 2016 at 01:43:41AM +0100, Daniel Borkmann wrote:
[...]
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index 751e806..a0fca9f 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -682,6 +682,17 @@ struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
>>   }
>>   EXPORT_SYMBOL_GPL(bpf_prog_add);
>>
>> +void bpf_prog_sub(struct bpf_prog *prog, int i)
>> +{
>> +	/* Only to be used for undoing previous bpf_prog_add() in some
>> +	 * error path. We still know that another entity in our call
>> +	 * path holds a reference to the program, thus atomic_sub() can
>> +	 * be safely used in such cases!
>> +	 */
>> +	WARN_ON(atomic_sub_return(i, &prog->aux->refcnt) == 0);
>> +}
>> +EXPORT_SYMBOL_GPL(bpf_prog_sub);
>
> the patches look good. I'm only worried about net/net-next merge
> conflict here. (I would have to deal with it as well).
> So instead of copying the above helper can we apply net-next's
> 'bpf, mlx4: fix prog refcount in mlx4_en_try_alloc_resources error path'
> patch to net without mlx4_xdp_set hunk and then apply
> the rest of this patch?
> Even better is to send this patch 2/3 to net-next?
> yes, it's an issue, but very small one. There is no security
> concern here, so I would prefer to avoid merge conflict.
> Did you do a test merge of net/net-next by any chance?

Yes, I did a test merge and git resolved the above just fine w/o
any conflicts. I have no strong opinion whether net or net-next.
If preferred, I can just resend this series in the evening against
net-next instead, perhaps that's a bit better.

Thanks,
Daniel
