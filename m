From: Yuchung Cheng <ycheng@google.com>
Subject: Re: a F-RTO question
Date: Tue, 27 Mar 2012 22:35:34 -0700
Message-ID: <CAK6E8=cgHxQMXA9QVu6=v6OqRAd6v7-wsEpM9ENFhqDpn88GvQ@mail.gmail.com>
References: <4F7281ED.1060603@gmail.com> <CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com>
 <4F728EC9.1050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chao Pei <peichao85@gmail.com>, netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52141 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab2C1Ffz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 01:35:55 -0400
Received: by obbeh20 with SMTP id eh20so869721obb.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 22:35:54 -0700 (PDT)
In-Reply-To: <4F728EC9.1050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 9:08 PM, Li Yu <raise.sail@gmail.com> wrote:
> =D3=DA 2012=C4=EA03=D4=C228=C8=D5 11:49, Chao Pei =D0=B4=B5=C0:
>
>>> Hi,
>>>
>>>        I have a question about tcp_process_frto(), the below source
>>> code :
>>>
>>> static int tcp_process_frto(struct sock *sk, int flag)
>>> {
>>>        .....
>>>
>>>        if (!before(tp->snd_una, tp->frto_highmark)) {
>>>                tcp_enter_frto_loss(sk, ...);
>>>                return 1;
>>>        }
>>>
>>>        .....
>>>
>>> }
>>>
>>>        As my understanding, the tp->frto_highmark likes tp->high_se=
q,
>>> it saves the seqno SND_NXT when a TCP connection enters F-RTO phase=
,
>>> is it the variable "recovery" in NewReno? So I think that if snd_un=
a is
>>> equal with or after frto_highmark, which means peer ack new data, s=
o
>>> why we enter Loss state here?
>>>
>>>        Thanks!
>>>
>>> Yu
>>>
>>>
>>
>> If snd_una advances to frto_highmark, it is likely that the hole was
>> filled by the retransimitted packet, which means the original packet
>> was likely to have been lost.
>> So, we should enter loss state.
>>
>
> I do not agree with it, if snd_una advanced to frto_highmark, which m=
eans
> peer acks whole window of data instead of just one segment, and
> we can not make sure that reason of peer sends ack is whether it rece=
ived
> original segment or retransmitted segment.
>
> Even, the reason is latter, it also means the netowrk already is
> recovered from temporarily congestion or disordered state, so we also=
 should
> not enter loss state.
Like you said there is some ambiguity and F-RTO takes the conservative =
approach.
You can find answers to your question in RFC 5682  (Section 2.2). Unles=
s the RTO
is proven to be spurious, TCP should reduce window and performs
slow-start regardlessly.
