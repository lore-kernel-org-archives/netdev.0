From: Li Yu <raise.sail@gmail.com>
Subject: Re: a F-RTO question
Date: Wed, 28 Mar 2012 12:08:41 +0800
Message-ID: <4F728EC9.1050302@gmail.com>
References: <4F7281ED.1060603@gmail.com> <CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chao Pei <peichao85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40237 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696Ab2C1EI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 00:08:56 -0400
Received: by iagz16 with SMTP id z16so891254iag.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 21:08:56 -0700 (PDT)
In-Reply-To: <CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B403=E6=9C=8828=E6=97=A5 11:49, Chao Pei =E5=86=99=
=E9=81=93:
>> Hi,
>>
>>         I have a question about tcp_process_frto(), the below source
>> code :
>>
>> static int tcp_process_frto(struct sock *sk, int flag)
>> {
>>         .....
>>
>>         if (!before(tp->snd_una, tp->frto_highmark)) {
>>                 tcp_enter_frto_loss(sk, ...);
>>                 return 1;
>>         }
>>
>>         .....
>>
>> }
>>
>>         As my understanding, the tp->frto_highmark likes tp->high_se=
q,
>> it saves the seqno SND_NXT when a TCP connection enters F-RTO phase,
>> is it the variable "recovery" in NewReno? So I think that if snd_una=
 is
>> equal with or after frto_highmark, which means peer ack new data, so
>> why we enter Loss state here?
>>
>>         Thanks!
>>
>> Yu
>>
>>
>
> If snd_una advances to frto_highmark, it is likely that the hole was
> filled by the retransimitted packet, which means the original packet
> was likely to have been lost.
> So, we should enter loss state.
>

I do not agree with it, if snd_una advanced to frto_highmark, which=20
means peer acks whole window of data instead of just one segment, and
we can not make sure that reason of peer sends ack is whether it=20
received original segment or retransmitted segment.

Even, the reason is latter, it also means the netowrk already is
recovered from temporarily congestion or disordered state, so we also=20
should not enter loss state.

Thanks

Yu
