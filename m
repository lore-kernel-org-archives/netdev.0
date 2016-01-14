From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RT] net: move xmit_recursion to per-task variable on -RT
Date: Fri, 15 Jan 2016 00:00:37 +0100
Message-ID: <56982895.6070901@stressinduktion.org>
References: <20160113152352.GH29964@linutronix.de>
 <alpine.DEB.2.11.1601131830440.3575@nanos>
 <20160114145007.GC17776@linutronix.de> <56981AE1.20202@stressinduktion.org>
 <1452810004.1223.154.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1452810004.1223.154.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.01.2016 23:20, Eric Dumazet wrote:
> On Thu, 2016-01-14 at 23:02 +0100, Hannes Frederic Sowa wrote:
>
>> We are just adding a second recursion limit solely to openvswitch which
>> has the same problem:
>>
>> https://patchwork.ozlabs.org/patch/566769/
>>
>> This time also we depend on rcu_read_lock marking the section being
>> nonpreemptible. Nice would be a more generic solution here which doesn't
>> need to always add something to *current.
>
>
> Note that rcu_read_lock() does not imply that preemption is disabled.

Exactly, it is conditional on CONFIG_PREEMPT_CPU/CONFIG_PREMPT_COUNT but 
haven't thought about exactly that in this moment.

I will resend this patch with better protection.

Thanks Eric!
