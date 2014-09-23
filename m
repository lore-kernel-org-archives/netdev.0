From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: Fix TLP implementation in case receive window
 limits send
Date: Tue, 23 Sep 2014 10:54:55 -0700
Message-ID: <CAK6E8=f5GcgX5kuyeOWqhmj2t1KyeyiBqdfehP4V52miUT83LA@mail.gmail.com>
References: <6cbd68ba1ef44c5ca4b21bd3f65846af@AM3PR06MB388.eurprd06.prod.outlook.com>
 <CAK6E8=eRUq1K5XRt9Ofzn7YWnfc7qP9ndrrF2hm0VXsPXYAeEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Itzcak Pechtalt <itzcak@flashnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:47283 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293AbaIWRzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 13:55:37 -0400
Received: by mail-ie0-f181.google.com with SMTP id tr6so9895320ieb.12
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 10:55:36 -0700 (PDT)
In-Reply-To: <CAK6E8=eRUq1K5XRt9Ofzn7YWnfc7qP9ndrrF2hm0VXsPXYAeEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014 at 10:52 AM, Yuchung Cheng <ycheng@google.com> wrote:
> On Tue, Sep 23, 2014 at 9:28 AM, Itzcak Pechtalt
> <itzcak@flashnetworks.com> wrote:
>> From: Itzcak Pechtalt <itzcak@flashnetworks.com>
>>
>> TCP Tail loss probe (TLP) algorithm implementation has some problem.
>> According to paper (draft-dukkipati-tcpm-tcp-loss-probe-0 ):
>> In case recive window of receiver limits send of new packet in probe time than
>> a retransmit of last packet send should be done.
>>
>> Actually, return code from tcp_write_xmit is not checked and only RTO is
>> scheduled,
>> So, it will take more time for reovery in this case than without TLP.
>>
>> Signed-off-by: Itzcak Pechtalt <itzcak@flashnetworks.com>
>> ---
>> net/ipv4/tcp_output.c  |    2 +-
>> 1 file changed, 1 insertions(+),  1 deletions(-)
>>
>> diff -up a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> --- a/net/ipv4/tcp_output.c     2014-09-23 18:35:37.113771694 +0300
>> +++ b/net/ipv4/tcp_output.c     2014-09-23 18:39:58.207726420 +0300
>> @@ -2100,7 +2100,8 @@ void tcp_send_loss_probe(struct sock *sk
>>
>>         if (tcp_send_head(sk) != NULL) {
>>                 err = tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
>> -              goto rearm_timer;
> Doesn't tcp_write_xmit() return true if tcp_snd_wnd_test() fails? not
> sure I understand the fix.
Oops I read an old version of the code. Nevermind...

>
>> +             if (!err)
>> +                       goto rearm_timer;
>>         }
>>
>>         /* At most one outstanding TLP retransmission. */
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
