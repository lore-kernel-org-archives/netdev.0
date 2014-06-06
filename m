From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: filter: fix typo in sparc BPF JIT
Date: Fri, 6 Jun 2014 08:27:16 -0700
Message-ID: <CAMEtUux-zmM0Ry4kRiL5D+AvQnby0Qn-mCxJSEyyvoEyUBE7Zg@mail.gmail.com>
References: <1402033664-14551-1-git-send-email-ast@plumgrid.com>
	<063D6719AE5E284EB5DD2968C1650D6D172584FF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:41258 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaFFP1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:27:17 -0400
Received: by mail-wg0-f42.google.com with SMTP id y10so2936914wgg.13
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 08:27:16 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172584FF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 6, 2014 at 1:36 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexei Starovoitov
>> fix typo in sparc codegen for SKF_AD_IFINDEX and SKF_AD_HATYPE
>> classic BPF extensions
> ...
>> --- a/arch/sparc/net/bpf_jit_comp.c
>> +++ b/arch/sparc/net/bpf_jit_comp.c
>> @@ -83,9 +83,9 @@ static void bpf_flush_icache(void *start_, void *end_)
>>  #define BNE          (F2(0, 2) | CONDNE)
>>
>>  #ifdef CONFIG_SPARC64
>> -#define BNE_PTR              (F2(0, 1) | CONDNE | (2 << 20))
>> +#define BE_PTR               (F2(0, 1) | CONDE | (2 << 20))
>>  #else
>> -#define BNE_PTR              BNE
>> +#define BE_PTR               BNE
>>  #endif
>
> That doesn't look right.
> AFAICT you've had to invert the branch in the code (below) so need
> the alternate define - I presume this is the only place they are used.
> But the second is only partially inverted.

Ohh. yes. sorry. It's a copy paste error from net-next into net :((
I fixed it carefully in net-next first, then tried to git am, had to
do it manually, built/ran sparc64 only.

> I presume you only tested sparc64?

yes. I don't have it setup yet.

>         David
>
>>  #define SETHI(K, REG)        \
>> @@ -600,7 +600,7 @@ void bpf_jit_compile(struct sk_filter *fp)
>>                       case BPF_S_ANC_IFINDEX:
>>                               emit_skb_loadptr(dev, r_A);
>>                               emit_cmpi(r_A, 0);
>> -                             emit_branch(BNE_PTR, cleanup_addr + 4);
>> +                             emit_branch(BE_PTR, cleanup_addr + 4);
>>                               emit_nop();
>>                               emit_load32(r_A, struct net_device, ifindex, r_A);
>>                               break;
>> @@ -613,7 +613,7 @@ void bpf_jit_compile(struct sk_filter *fp)
>>                       case BPF_S_ANC_HATYPE:
>>                               emit_skb_loadptr(dev, r_A);
>>                               emit_cmpi(r_A, 0);
>> -                             emit_branch(BNE_PTR, cleanup_addr + 4);
>> +                             emit_branch(BE_PTR, cleanup_addr + 4);
>>                               emit_nop();
>>                               emit_load16(r_A, struct net_device, type, r_A);
>>                               break;
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
