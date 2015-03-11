From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 12:18:16 -0700
Message-ID: <CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	<CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	<1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:42968 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbCKTSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 15:18:17 -0400
Received: by igkb16 with SMTP id b16so15234654igk.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 12:18:17 -0700 (PDT)
In-Reply-To: <1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 11:25 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-11 at 11:08 -0700, Cong Wang wrote:
>> On Wed, Mar 11, 2015 at 10:34 AM, Cong Wang <cwang@twopensource.com> wrote:
>> >
>> > Given that skb->priority can be specified in user-space, doesn't this
>> > mean some application can always override our rules specified by tc
>> > filters? I think we should always respect tc filters over any
>> > application setting.
>> >
>>
>> Hmm, on the other hand, skb->priority can be changed in cgroup
>> too, in this case the current behavior seems correct. :-/ Interesting.
>
> Note that even HTB has the following code :
>

I am not surprised.

[...]

>
> So if skb->priority happens to match sch->handle or any class handle,
> we queue packet into a queue, without calling tc_classify()

This is exactly why I am asking, kernel respects user's choice so much
that it could override even both cgroup prio and tc filters, I don't know
what is the reason behind, but this means our tc filters can not work
with an application which sets skb->priority. For example, our tc filters
classify the packets from this socket into flow 1:1, but application
sets 1:2 by itself...
