From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH 1/2 nf] netfilter: seqadj: Fix some possible panics of
 seqadj when mem is exhausted
Date: Fri, 2 Sep 2016 12:57:33 +0800
Message-ID: <CA+6hz4pphci3V=pjuQaYx5YLDqMUG=Q7bKy7gtHLTZyyuZ9oPg@mail.gmail.com>
References: <1472780905-13094-1-git-send-email-fgao@ikuai8.com> <CAML_gOe+Ao5WEuVbTry_oekwsm2-ooZ074pgfpzxYzNehgLGjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOe+Ao5WEuVbTry_oekwsm2-ooZ074pgfpzxYzNehgLGjQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Liping,

On Fri, Sep 2, 2016 at 12:50 PM, Liping Zhang <zlpnobody@gmail.com> wrote:
> Hi Feng,
> 2016-09-02 9:48 GMT+08:00  <fgao@ikuai8.com>:
>> From: Gao Feng <fgao@ikuai8.com>
>> @@ -171,6 +176,11 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
>>         struct nf_ct_seqadj *this_way, *other_way;
>>         int res;
>>
>> +       if (unlikely(!seqadj)) {
>
> IPS_SEQ_ADJUST_BIT will be tested before we call nf_ct_seq_adjust(),
> so I think seqadj
> will never be NULL here.

Thanks. I didn't check  IPS_SEQ_ADJUST_BIT  flag.

>
>> +               WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
>> +               return 0;
>> +       }
>> +
>>         this_way  = &seqadj->seq[dir];
>>         other_way = &seqadj->seq[!dir];
>>
>> @@ -218,8 +228,10 @@ s32 nf_ct_seq_offset(const struct nf_conn *ct,
>>         struct nf_conn_seqadj *seqadj = nfct_seqadj(ct);
>>         struct nf_ct_seqadj *this_way;
>>
>> -       if (!seqadj)
>> +       if (unlikely(!seqadj)) {
>> +               WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
>
> But in nf_ct_seq_offset, seqadj is likely to be NULL, see the function
> call path:
> tcp_packet->tcp_in_window->nf_ct_seq_offset, so WARN_ONCE seems unnecessary.
>
>>                 return 0;
>> +       }

Get it. It could be NULL.

Then only nf_ct_seqadj_init is necessary to check seqadj.
I will update this patch.

Regards
Feng


