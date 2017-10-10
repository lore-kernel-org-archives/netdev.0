From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH][net-next] ipv6: fix incorrect bitwise operator used on rt6i_flags
Date: Tue, 10 Oct 2017 11:23:41 -0700
Message-ID: <CAEA6p_BDQ_RaF7-9eBnhstMY_w-i91cJECXuvSHntkdDQo-YUw@mail.gmail.com>
References: <20171010175527.21982-1-colin.king@canonical.com> <20171010181054.4snwnyc3q7rf2wbl@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        lkml <linux-kernel@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>,
        Colin King <colin.king@canonical.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010181054.4snwnyc3q7rf2wbl@kafai-mbp.dhcp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 11:10 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Tue, Oct 10, 2017 at 05:55:27PM +0000, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> The use of the | operator always leads to true on the expression
>> (rt->rt6i_flags | RTF_CACHE) which looks rather suspect to me. I
>> believe this is fixed by using & instead to just check the
>> RTF_CACHE entry bit.
> Good catch. LGTM. If rt does not have RTF_CACHE set, it should not be in the
> exception table.
>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
>

Thanks a lot for catching this. Yes. It should have been '&' instead of '|'.

Acked-by: Wei Wang <weiwan@google.com>

>>
>> Detected by CoverityScan, CID#1457747 ("Wrong operator used")
>>
>> Fixes: 35732d01fe31 ("ipv6: introduce a hash table to store dst cache")
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  net/ipv6/route.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 6db1541eaa7b..0556d1ee189c 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1425,7 +1425,7 @@ int rt6_remove_exception_rt(struct rt6_info *rt)
>>       int err;
>>
>>       if (!from ||
>> -         !(rt->rt6i_flags | RTF_CACHE))
>> +         !(rt->rt6i_flags & RTF_CACHE))
>>               return -EINVAL;
>>
>>       if (!rcu_access_pointer(from->rt6i_exception_bucket))
>> --
>> 2.14.1
>>
