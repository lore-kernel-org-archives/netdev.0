From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 10/12] xdp: Add batching support to redirect map
Date: Mon, 10 Jul 2017 10:56:54 -0700
Message-ID: <5963BFE6.2050403@gmail.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810> <20170707173759.9984.5709.stgit@john-Precision-Tower-5810> <20170710195355.40fd9caa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36071 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754594AbdGJR5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 13:57:05 -0400
Received: by mail-pg0-f67.google.com with SMTP id u36so13589180pgn.3
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 10:57:05 -0700 (PDT)
In-Reply-To: <20170710195355.40fd9caa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2017 10:53 AM, Jesper Dangaard Brouer wrote:
> On Fri, 07 Jul 2017 10:37:59 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
>> index 36dc13de..656e334 100644
>> --- a/kernel/bpf/devmap.c
>> +++ b/kernel/bpf/devmap.c
> [...]
>>  
>> +void __dev_map_insert_ctx(struct bpf_map *map, u32 key)
>> +{
>> +	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
>> +	unsigned long *bitmap = this_cpu_ptr(dtab->flush_needed);
>> +
>> +	set_bit(key, bitmap);
>> +}
> 
> I don't like that this adds an atomic op (set_bit) per packet on a fast-path.
> It shows up on a perf top #6 with xdp_redirect_map.
> 

Its a per cpu bitmap so __set_bit() should be fine here.

Thanks,
John
