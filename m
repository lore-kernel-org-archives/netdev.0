From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 10:53:01 -0700
Message-ID: <CAM_iQpXgP=-S364Bza5fU9nROXD9dYYcUbkEJtn59UcFHAOgXA@mail.gmail.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
 <570BA8C7.1000905@axis.com> <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
 <570BC024.1070504@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lars Persson <larper@axis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Lars Persson <lars.persson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570BC024.1070504@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 8:17 AM, Lars Persson <lars.persson@axis.com> wrote:
>
>
> On 04/11/2016 04:22 PM, Eric Dumazet wrote:
>>
>> On Mon, 2016-04-11 at 15:38 +0200, Lars Persson wrote:
>>
>>> I though it would be prudent because the queue can be non-empty even for
>>> the case of skb=NULL. So should it be there in this patch, another patch
>>> or not at all ?
>>
>>
>> Then maybe change return code ?
>>
>> It seems strange that a validate_xmit_skb_list() failure stops the
>> __qdisc_run() loop but schedules another round.
>>
>>
>
> It was suggested by Cong Wang to return 0 in order to stop the loop. Do you
> guys agree that the loop should be stopped for such failures ? Then I will
> put the schedule call inside the if as you proposed earlier.

I don't see any reason why we should continue on failure. And, I didn't
suggest you to return reschedule it either. I was suggesting to just return
0 for skb == NULL case.
