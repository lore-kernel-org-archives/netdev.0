From: starlight.2015q2@binnacle.cx
Subject: Re: 2.6.32.66 tcp regression OOPs
Date: Mon, 01 Jun 2015 11:32:19 -0400
Message-ID: <6.2.5.6.2.20150601113107.07232e78@binnacle.cx>
References: <6.2.5.6.2.20150531210751.0722ad10@binnacle.cx>
 <CAH6sp9O9sqKuamwF38JZLh+K2QKXNB7RRJ8cPtz+1h6MV7foYg@mail.gmail.com>
 <20150601074922.GA28740@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>, Frans Klaver <fransklaver@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150601074922.GA28740@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I found the patch late yesterday and applied it.

Running fine now for 12 hours under active load.

Recommend the patch be rolled into the tarball,
or a notation added to the release page as this
one has severe consequences.

Thank You!


At 09:49 6/1/2015 +0200, Willy Tarreau wrote:
>Hi,
>
>On Mon, Jun 01, 2015 at 09:00:21AM +0200, Frans Klaver wrote:
>> [cc: Willy Tarreau]
>> 
>> On Mon, Jun 1, 2015 at 3:26 AM,  
><starlight.2015q2@binnacle.cx> wrote:
>> > Hello,
>> >
>> > Apoligies if I have submitted to the wrong lists.
>> >
>> > Encountered a regression in
>> > 2.6.32.66 relative to 2.6.32.65.
>> >
>> > Crash eight minutes after boot.
>> >
>> > Will responded with additional details
>> > if the OOPS is not sufficent.
>> >
>> > Best Regards
>> >
>> 
>> Did you bisect it?
>
>Eric Dumazet notified me that of something possibly similar due to
>a mistake I made when backporting a fix by hand.
>
>Please apply the following patch to see if it fixes the problem 
>:
>
>diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c       
>               
>index 5339f066234b..d1e2895bb63c 100644                          
>               
>--- a/net/ipv4/tcp_output.c
>+++ b/net/ipv4/tcp_output.c
>@@ -2136,7 +2136,7 @@ void tcp_send_fin(struct sock *sk)
>	*/
>	if (tskb && (tcp_send_head(sk) || tcp_memory_pressure)) {
> coalesce:
>-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
>+		TCP_SKB_CB(tskb)->flags |= TCPCB_FLAG_FIN;
>		TCP_SKB_CB(tskb)->end_seq++;
>		tp->write_seq++;
>	if (!tcp_send_head(sk)) {
>
>Thanks,
>Willy
