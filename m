From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH v2 1/2 nf] netfilter: seqadj: Fix one possible panic in
 seqadj when mem is exhausted
Date: Fri, 2 Sep 2016 15:07:13 +0800
Message-ID: <CA+6hz4qNAu+nbtBgAMHJAxPNvagkQzbNn88M4h6b7pKX3-BfMw@mail.gmail.com>
References: <1472792932-26187-1-git-send-email-fgao@ikuai8.com> <20160902065914.GC8883@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160902065914.GC8883@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Fri, Sep 2, 2016 at 2:59 PM, Florian Westphal <fw@strlen.de> wrote:
> fgao@ikuai8.com <fgao@ikuai8.com> wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
>> extension. But the function nf_ct_seqadj_init doesn't check if get valid
>> seqadj pointer by the nfct_seqadj, while other functions perform the
>> sanity check.
>>
>> So the system would be panic when nfct_seqadj_ext_add failed.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>
>> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
>> index dff0f0c..2c8e201 100644
>> --- a/net/netfilter/nf_conntrack_seqadj.c
>> +++ b/net/netfilter/nf_conntrack_seqadj.c
>> @@ -16,9 +16,14 @@ int nf_ct_seqadj_init(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
>>       if (off == 0)
>>               return 0;
>>
>> +     seqadj = nfct_seqadj(ct);
>> +     if (unlikely(!seqadj)) {
>> +             WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
>> +             return 0;
>> +     }
>> +
>
> Not sure this WARN() is really needed, I would remove it (since its most
> likely only missing due to memory shortage).
>
> Other than that, this looks good.
>

I prefer to keep the warning, although it only happens caused by mem
shortage now.
But it would give the accurate description, if the nfct_seqadj_ext_add
was lost when new features were depending on synadj.


Best Regards
Feng


