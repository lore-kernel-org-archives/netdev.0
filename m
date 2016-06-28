From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: =?UTF-8?Q?Re:_IP_ID_check_=28flush=5fid=29_in_inet=5fgro=5freceive_?=
 =?UTF-8?Q?is_necessary_or_not=ef=bc=9f?=
Date: Tue, 28 Jun 2016 15:44:00 +0800
Message-ID: <57722AC0.7090003@huawei.com>
References: <5771FFA1.3050306@huawei.com>
 <1467089829.6850.181.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<aduyck@mirantis.com>, <hkchu@google.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467089829.6850.181.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/6/28 12:57, Eric Dumazet wrote:
> On Tue, 2016-06-28 at 12:40 +0800, Tan Xiaojun wrote:
>> Hi everyone,
>>
>> 	I'm sorry to bother you. But I was confused.
>>
>> 	The IP ID check (flush_id) in inet_gro_receive is only used by
>> tcp_gro_receive, and in tcp_gro_receive we have tcphdr check to ensure
>> the order of skbs,
>> 	like below:
>>
>> 	flush |= (__force int)(th->ack_seq ^ th2->ack_seq);
>> 	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
>>
>> 	So if I remove the IP ID check in inet_gro_receive, there will be a
>> problem ? And under what circumstances ?
> 
> You probably missed a recent patch ?
> 

Thank you very much. 

Is this patch means forcing the IP ID to be incrementing by 1 is necessary in the
case of using tunnel (if the IP_DF is not set in frag_off).

I have not used the tunneled frames. Do you have some examples for that ?

Xiaojun.

> commit 1530545ed64b42e87acb43c0c16401bd1ebae6bf
> Author: Alexander Duyck <aduyck@mirantis.com>
> Date:   Sun Apr 10 21:44:57 2016 -0400
> 
>     GRO: Add support for TCP with fixed IPv4 ID field, limit tunnel IP ID values
>     
>     This patch does two things.
>     
>     First it allows TCP to aggregate TCP frames with a fixed IPv4 ID field.  As
>     a result we should now be able to aggregate flows that were converted from
>     IPv6 to IPv4.  In addition this allows us more flexibility for future
>     implementations of segmentation as we may be able to use a fixed IP ID when
>     segmenting the flow.
>     
>     The second thing this does is that it places limitations on the outer IPv4
>     ID header in the case of tunneled frames.  Specifically it forces the IP ID
>     to be incrementing by 1 unless the DF bit is set in the outer IPv4 header.
>     This way we can avoid creating overlapping series of IP IDs that could
>     possibly be fragmented if the frame goes through GRO and is then
>     resegmented via GSO.
>     
>     Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
> 
> .
> 
