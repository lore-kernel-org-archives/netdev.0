From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 2/2] bpf: sock_map fixes for !CONFIG_BPF_SYSCALL
 and !STREAM_PARSER
Date: Wed, 16 Aug 2017 15:20:53 -0700
Message-ID: <5994C545.8060305@gmail.com>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810> <20170816220232.25438.47447.stgit@john-Precision-Tower-5810> <1b280444-18dc-7207-1708-f651a1cf2a52@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>, daniel@iogearbox.net,
        davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36828 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752570AbdHPWVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:21:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id y129so6632249pgy.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:21:05 -0700 (PDT)
In-Reply-To: <1b280444-18dc-7207-1708-f651a1cf2a52@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2017 03:06 PM, David Ahern wrote:
> On 8/16/17 4:02 PM, John Fastabend wrote:
>> diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
>> index aa24287..897daa0 100644
>> --- a/kernel/bpf/Makefile
>> +++ b/kernel/bpf/Makefile
>> @@ -3,7 +3,10 @@ obj-y := core.o
>>  obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o
>>  obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
>>  ifeq ($(CONFIG_NET),y)
>> -obj-$(CONFIG_BPF_SYSCALL) += devmap.o sockmap.o
>> +obj-$(CONFIG_BPF_SYSCALL) += devmap.o
>> +ifeq ($(CONFIG_STREAM_PARSER),y)
>> +obj-$(CONFIG_BPF_SYSCALL) += sockmap.o
>> +endif
>>  endif
> 
> sockmap requires KCM? I thought it just needed STREAM_PARSER. Can't
> STREAM_PARSER be used outside of KCM? If so why not make STREAM_PARSER
> enabled if sockmap is wanted vs requiring KCM to be compiled in to get
> stream parser to get sockmap?
> 

KCM is not required all sockmap needs is STREAM_PARSER. STREAM_PARSER can
be used outside of KCM so no problem there.

I didn't want to require all users of BPF maps to automatically get
STREAM_PARSER however. I'll add a Kconfig option for STREAM_PARSER so we
can pull it in without KCM easily. This is very similar to how the cgroup
BPF build logic works as well with CONFIG_CGROUP_BPF.

I wanted to get the build fix out though as soon as possible rather than
wait for me to write the STREAM_PARSER patch and test it.

Thanks,
John
