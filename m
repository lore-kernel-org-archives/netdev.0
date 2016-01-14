From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RT] net: move xmit_recursion to per-task variable on -RT
Date: Thu, 14 Jan 2016 23:02:09 +0100
Message-ID: <56981AE1.20202@stressinduktion.org>
References: <20160113152352.GH29964@linutronix.de>
 <alpine.DEB.2.11.1601131830440.3575@nanos>
 <20160114145007.GC17776@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160114145007.GC17776@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.01.2016 15:50, Sebastian Andrzej Siewior wrote:
> * Thomas Gleixner | 2016-01-13 18:31:46 [+0100]:
>
>> On Wed, 13 Jan 2016, Sebastian Andrzej Siewior wrote:
>>> +#ifdef CONFIG_PREEMPT_RT_FULL
>>> +static inline int dev_recursion_level(void)
>>> +{
>>> +	return atomic_read(&current->xmit_recursion);
>>
>> Why would you need an atomic here. current does hardly race against itself.
>
> right.

We are just adding a second recursion limit solely to openvswitch which 
has the same problem:

https://patchwork.ozlabs.org/patch/566769/

This time also we depend on rcu_read_lock marking the section being 
nonpreemptible. Nice would be a more generic solution here which doesn't 
need to always add something to *current.

Thanks,
Hannes
