From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: Reset skb to network header in neigh_hh_output
Date: Fri, 7 Oct 2016 19:38:06 +0300
Message-ID: <f1a14f84-f9f9-4cec-94ee-fce7ced6c9d1@cogentembedded.com>
References: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com>
 <572cddd1-6a03-4c83-1e0e-55be37273396@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Abdelrhman Ahmed <ab@abahmed.com>, davem <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <572cddd1-6a03-4c83-1e0e-55be37273396@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2016 07:27 PM, Sergei Shtylyov wrote:

>> When hardware header is added without using cached one, neigh_resolve_output
>> and neigh_connected_output reset skb to network header before adding it.
>> When cached one is used, neigh_hh_output does not reset the skb to network
>> header.
>>
>> The fix is to reset skb to network header before adding cached hardware header
>> to keep the behavior consistent in all cases.
>>
>> Signed-off-by: Abdelrhman Ahmed <ab@abahmed.com>
>> ---
>>  include/net/neighbour.h | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
>> index 8b68384..4d89fc2 100644
>> --- a/include/net/neighbour.h
>> +++ b/include/net/neighbour.h
>> @@ -424,7 +424,7 @@ static inline struct neighbour * neigh_clone(struct
>> neighbour *neigh)
>>  static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff
>> *skb)
>>  {
>>         unsigned long now = jiffies;
>> -
>> +
>
>    Unraleted white-space change.

    And I thought I fixed this word... it's "unrelated" of/c. :-)

>
>>         if (neigh->used != now)
>>                 neigh->used = now;
>>         if (!(neigh->nud_state&(NUD_CONNECTED|NUD_DELAY|NUD_PROBE)))
> [...]

MBR, Sergei
