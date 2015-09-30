From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 14:25:58 +0100
Message-ID: <87pp10t4wp.fsf@doppelsaurus.mobileactivedefense.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
	<CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
	<87612skwfb.fsf@doppelsaurus.mobileactivedefense.com>
	<CA+rthh_LqYaOBBMmdCa=zo55ukVDTff-pKM8cw0HzJDapg5Vvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz\@infradead.org" <peterz@infradead.org>,
	"davem\@davemloft.net" <davem@davemloft.net>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+rthh_LqYaOBBMmdCa=zo55ukVDTff-pKM8cw0HzJDapg5Vvg@mail.gmail.com>
	(Mathias Krause's message of "Wed, 30 Sep 2015 13:55:57 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mathias Krause <minipli@googlemail.com> writes:
> On 30 September 2015 at 12:56, Rainer Weikusat <rweikusat@mobileactivedefense.com> wrote:
>> Mathias Krause <minipli@googlemail.com> writes:
>>> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>>>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>>>> drop the reference on the original socket 'o'. Thus, we can now close socket
>>>> 'o' without unregistering from epoll. Then, when we either close the ep
>>>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>>>> race per se, but can be triggered sequentially.
>>>
>>> Sounds profound, but the reproducers calls connect only once per
>>> socket. So there is no "connect to a new socket", no?
>>> But w/e, see below.
>>
>> In case you want some information on this: This is a kernel warning I
>> could trigger (more than once) on the single day I could so far spend
>> looking into this (3.2.54 kernel):
>>
>> Sep 15 19:37:19 doppelsaurus kernel: WARNING: at lib/list_debug.c:53 list_del+0x9/0x30()
>> Sep 15 19:37:19 doppelsaurus kernel: Hardware name: 500-330nam
>> Sep 15 19:37:19 doppelsaurus kernel: list_del corruption. prev->next should be ffff88022c38f078, but was dead000000100100
>> [snip]
>
> Is that with Jason's patch or a vanilla v3.2.54?

That's a kernel warning which occurred repeatedly (among other "link 
pointer disorganization" warnings) when I tested the "program with
unknown behaviour" you wrote with the kernel I'm currently supporting a
while ago (as I already wrote in the original mail).
