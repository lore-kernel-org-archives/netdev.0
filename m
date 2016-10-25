From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] bpf: Refactor cgroups code in prep for new
 type
Date: Tue, 25 Oct 2016 17:04:41 -0600
Message-ID: <22db4876-eb97-bc1b-5d56-7d24bf43b960@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-2-git-send-email-dsa@cumulusnetworks.com>
 <580FE44F.2030403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34535 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754103AbcJYXEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 19:04:44 -0400
Received: by mail-pf0-f182.google.com with SMTP id n85so10457451pfi.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 16:04:44 -0700 (PDT)
In-Reply-To: <580FE44F.2030403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/16 5:01 PM, Daniel Borkmann wrote:
>> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
>> index a0ab43f264b0..918c01a6f129 100644
>> --- a/kernel/bpf/cgroup.c
>> +++ b/kernel/bpf/cgroup.c
>> @@ -117,6 +117,19 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
>>       }
>>   }
>>
>> +static int __cgroup_bpf_run_filter_skb(struct sk_buff *skb,
>> +                       struct bpf_prog *prog)
>> +{
>> +    unsigned int offset = skb->data - skb_network_header(skb);
>> +    int ret;
>> +
>> +    __skb_push(skb, offset);
>> +    ret = bpf_prog_run_clear_cb(prog, skb) == 1 ? 0 : -EPERM;
> 
> Original code save skb->cb[], this one clears it.
> 

ah, it changed in Daniel's v6 to v7 code and I missed it. Will fix. Thanks for pointing it out.
