From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next fragmentation icmp v3 1/4] ipv4: introduce frag_expire_skip_icmp()
Date: Tue, 12 May 2015 08:13:32 -0700
Message-ID: <CACzMAJ+DrD2KOMLp+U_Ddj57b946kdut70oL5y8tLXpSDMnFfQ@mail.gmail.com>
References: <1431059199-7139-1-git-send-email-azhou@nicira.com>
	<1431059199-7139-2-git-send-email-azhou@nicira.com>
	<554CA61B.50501@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:47268 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751416AbbELPNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:13:33 -0400
Received: by mail-oi0-f52.google.com with SMTP id a37so8395817oic.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:13:33 -0700 (PDT)
In-Reply-To: <554CA61B.50501@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 5:03 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 5/8/2015 7:26 AM, Andy Zhou wrote:
>
>> Improve readability of skip ICMP for de-fragmentation expiration logic.
>> This change will also make the logic easier to maintain when the
>> following patches in this series are applied.
>
>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>   include/net/ip.h       | 10 ++++++++++
>>   net/ipv4/ip_fragment.c | 13 +++++++++----
>>   2 files changed, 19 insertions(+), 4 deletions(-)
>
>
>> diff --git a/include/net/ip.h b/include/net/ip.h
>> index d14af7e..f79193a 100644
>> --- a/include/net/ip.h
>> +++ b/include/net/ip.h
>> @@ -478,6 +478,16 @@ enum ip_defrag_users {
>>         IP_DEFRAG_MACVLAN,
>>   };
>>
>> +/* Return true if the value of 'user' is between 'lower_bond'
>> + * and 'upper_bond' inclusively.
>> + */
>> +static inline bool ip_defrag_user_in_between(u32 user,
>> +                                            enum ip_defrag_users
>> lower_bond,
>> +                                            enum ip_defrag_users
>> upper_bond)
>> +{
>> +       return (user >= lower_bond && user <= upper_bond);
>
>
>    Don't need parens around the *return* expression.
Thanks, I will fix this and the following site in the next version.
>
> [...]
>>
>> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
>> index cc1da6d..429cefa 100644
>> --- a/net/ipv4/ip_fragment.c
>> +++ b/net/ipv4/ip_fragment.c
>> @@ -173,6 +173,13 @@ static void ipq_kill(struct ipq *ipq)
>>         inet_frag_kill(&ipq->q, &ip4_frags);
>>   }
>>
>> +static bool frag_expire_skip_icmp(u32 user)
>> +{
>> +       return (user == IP_DEFRAG_AF_PACKET ||
>> +               ip_defrag_user_in_between(user, IP_DEFRAG_CONNTRACK_IN,
>> +                                         __IP_DEFRAG_CONNTRACK_IN_END));
>
>
>    Likewise.
>
> [...]
>
> WBR, Sergei
>
