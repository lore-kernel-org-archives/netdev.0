From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: Fix TLP implementation in case receive window
 limits send
Date: Wed, 24 Sep 2014 15:25:22 -0400
Message-ID: <CADVnQy=KofBtktTj+ZW6ZzbkoAxdq_Ks8sehdtQNbO00EbvfdQ@mail.gmail.com>
References: <6cbd68ba1ef44c5ca4b21bd3f65846af@AM3PR06MB388.eurprd06.prod.outlook.com>
	<CAK6E8=fQjqXbbbdCVR-yNBif7C7GRBnPNsq11V7QZbqgb7dtwQ@mail.gmail.com>
	<CAB_+Fg69V2msVt3dr76VrgdYBOivjsRnvwBAuSWpi-v7Jkd+6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>,
	Itzcak Pechtalt <itzcak@flashnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:51149 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbaIXTZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 15:25:24 -0400
Received: by mail-qg0-f48.google.com with SMTP id z107so6539002qgd.35
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 12:25:23 -0700 (PDT)
In-Reply-To: <CAB_+Fg69V2msVt3dr76VrgdYBOivjsRnvwBAuSWpi-v7Jkd+6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 3:00 PM, Nandita Dukkipati <nanditad@google.com> wrote:
>> On Tue, Sep 23, 2014 at 9:28 AM, Itzcak Pechtalt
>> <itzcak@flashnetworks.com> wrote:
>>> From: Itzcak Pechtalt <itzcak@flashnetworks.com>
>>>
>>> TCP Tail loss probe (TLP) algorithm implementation has some problem.
>>> According to paper (draft-dukkipati-tcpm-tcp-loss-probe-0 ):
>>> In case recive window of receiver limits send of new packet in probe time than
>>> a retransmit of last packet send should be done.
>>>
>>> Actually, return code from tcp_write_xmit is not checked and only RTO is
>>> scheduled,
>>> So, it will take more time for reovery in this case than without TLP.
>>>
>>> Signed-off-by: Itzcak Pechtalt <itzcak@flashnetworks.com>
>> Acked-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Nandita Dukkipati <nanditad@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

BTW, Itzcak, have you been able to construct a test case where
this patch now allows a TLP in a case where the sender is limited
by the receive window?

Often we will be prevented from doing any kind of TLP if we are
limited by the receive window, due to these lines in
tcp_schedule_loss_probe():

  if ((tp->snd_cwnd > tcp_packets_in_flight(tp)) &&
       tcp_send_head(sk))
          return false;

But there is something else going on as well, since I haven't been
able to force a TLP even when cwnd == rwin == tcp_packets_in_flight()
== 10. But I haven't had much time to spend on it.

neal
