From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next fragmenation icmp 1/2] ipv4_fragment: Add a bit in IPCB
 to control ICMP generation
Date: Wed, 6 May 2015 14:12:34 -0700
Message-ID: <CACzMAJJ7AEmC4aGShrc0sCkotLD7_TxhQwPUm1sdVdcNFNic-A@mail.gmail.com>
References: <1430877594-32054-1-git-send-email-azhou@nicira.com>
	<1430877594-32054-2-git-send-email-azhou@nicira.com>
	<1430915034.14545.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:52072 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751034AbbEFVMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 17:12:35 -0400
Received: by mail-oi0-f44.google.com with SMTP id a37so18236220oic.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 14:12:34 -0700 (PDT)
In-Reply-To: <1430915034.14545.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since I only need 1 bit for this, I can probably define and use one
more bit in the 'flags' field above.

Thanks for the review.  I will send out a 'v2'.


On Wed, May 6, 2015 at 5:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-05-05 at 18:59 -0700, Andy Zhou wrote:
>> Currently, on fragmentation or defragmentation error, ICMP error message
>> can be generated. This is fine when they are used in a routing context,
>> but does not make sense when they are used in a bridging context, i.e.
>> netfilter for bridging.
>>
>> This patch adds a bit in IPCB to control whether ICMP error message
>> should be generated.
>>
>> IPV6 fragmentation and defragmentation functions are not reused by
>> bridge netfilter. Thus, this change is only required for IPV4.
>>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>  include/net/inet_frag.h |  2 ++
>>  include/net/ip.h        |  1 +
>>  net/ipv4/ip_fragment.c  | 11 ++++++++++-
>>  net/ipv4/ip_output.c    |  5 +++--
>>  4 files changed, 16 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
>> index 8d17655..1d57045 100644
>> --- a/include/net/inet_frag.h
>> +++ b/include/net/inet_frag.h
>> @@ -44,6 +44,7 @@ enum {
>>   * @meat: length of received fragments so far
>>   * @flags: fragment queue flags
>>   * @max_size: (ipv4 only) maximum received fragment size with IP_DF set
>> + * @no_icmp:  Do not generate any fragmentation related icmp packet
>>   * @net: namespace that this frag belongs to
>>   */
>>  struct inet_frag_queue {
>> @@ -58,6 +59,7 @@ struct inet_frag_queue {
>>       int                     meat;
>>       __u8                    flags;
>>       u16                     max_size;
>> +     bool                    no_icmp;
>>       struct netns_frags      *net;
>>  };
>>
>
>
> What about filling the 8bit hole ?
>
>         int                     meat;
>         __u8                    flags;
> +       bool                    no_icmp;
>         u16                     max_size;
>         struct netns_frags      *net;
>
>
>
