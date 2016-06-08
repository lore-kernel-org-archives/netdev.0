From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net-next] sctp: sctp should change socket state when
 shutdown is received
Date: Wed, 8 Jun 2016 09:05:58 -0300
Message-ID: <6cdb1799-3e59-1f69-371c-a8737d336817@gmail.com>
References: <67353a74d044f1f643cdfe1442136b44d7188ea9.1464964965.git.lucien.xin@gmail.com>
 <20160603174918.GX22680@localhost.localdomain>
 <CADvbK_eCQiw4hhs84t2tj+6zSd7M8_ECNV+W+sviiGEG2WUX_g@mail.gmail.com>
 <72299bbd-475b-b39d-0f5f-6f1916cbe706@gmail.com>
 <CADvbK_eK0XUGr3+Nmnwy_sC9NHdWj-+k1BtnzNsjE516XBKcWQ@mail.gmail.com>
 <CADvbK_ekPqeApqFQx6fT_pJy4_3vFW0aLbsLeabUrSRM6bchtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:34441 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbcFHMGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 08:06:06 -0400
In-Reply-To: <CADvbK_ekPqeApqFQx6fT_pJy4_3vFW0aLbsLeabUrSRM6bchtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 08-06-2016 07:42, Xin Long escreveu:
> On Tue, Jun 7, 2016 at 7:03 PM, Xin Long <lucien.xin@gmail.com> wrote:
>> On Sat, Jun 4, 2016 at 8:22 PM, Marcelo Ricardo Leitner
>>
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -7565,10 +7565,12 @@ static void sctp_sock_migrate(struct sock
>> *oldsk, struct sock *newsk,
>>         /* If the association on the newsk is already closed before accept()
>>          * is called, set RCV_SHUTDOWN flag.
>>          */
>> -       if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP))
>> +       if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP)) {
>> +               newsk->sk_state = SCTP_SS_CLOSING;
>>                 newsk->sk_shutdown |= RCV_SHUTDOWN;
>> +       } else
>> +               newsk->sk_state = SCTP_SS_ESTABLISHED;
>>
>> -       newsk->sk_state = SCTP_SS_ESTABLISHED;
>>
> I'm still thinking about this, if we want to get addrs info from
> closed assoc, like Adam's requirement. this will make it more
> impossible.
>
> case in
> sctp_getsockopt_peer_addrs()->sctp_id2assoc():
>
>                 if (!sctp_sstate(sk, ESTABLISHED))
>                         return NULL;
>
> we can't  get assoc as sstate is SS_CLOSING already.
>

We probably can add another state to that if(). So far ESTABLISHED was 
the only reasonable state in there, but SS_CLOSING will make sense too 
then, I guess. A throughout check is necessary for this.

   Marcelo
