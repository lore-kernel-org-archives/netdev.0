From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Fri, 7 Feb 2014 14:49:20 -0800
Message-ID: <CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com>
	<20140207222840.GD16198@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Pravin <pshelar@nicira.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:51231 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751950AbaBGWtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 17:49:21 -0500
Received: by mail-vc0-f177.google.com with SMTP id if11so3118248vcb.22
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 14:49:20 -0800 (PST)
In-Reply-To: <20140207222840.GD16198@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 7, 2014 at 2:28 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi!
>
> On Fri, Feb 07, 2014 at 02:12:38PM -0800, Pravin wrote:
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3905,12 +3905,13 @@ EXPORT_SYMBOL(skb_try_coalesce);
>>   */
>>  void skb_scrub_packet(struct sk_buff *skb, bool xnet)
>>  {
>> -     if (xnet)
>> +     if (xnet) {
>>               skb_orphan(skb);
>> +             skb->local_df = 0;
>> +     }
>>       skb->tstamp.tv64 = 0;
>>       skb->pkt_type = PACKET_HOST;
>>       skb->skb_iif = 0;
>> -     skb->local_df = 0;
>>       skb_dst_drop(skb);
>>       skb->mark = 0;
>>       secpath_reset(skb);
>
> I wonder if this should be the right behaviour for tunnels, which should just
> do fragmentation based on IP_DF, even if the packet originated locally from a
> socket which allowed local fragmentation (inet->pmtudisc < IP_PMTUDISC_DO).
>
This is not about tunneling, skb_scrub_packet() is generic function
which should not reset local_df on all packets.

We can have separate discussion about use of local_df and tunneling in
another thread.
