From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 0/9] Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
Date: Thu, 20 Mar 2014 17:26:07 +0100
Message-ID: <532B169F.9030707@broadcom.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com> <532B022C.8010505@broadcom.com> <20140320150601.GK4405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Monam Agarwal <monamagarwal123@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<eddie.wai@broadcom.com>
To: <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140320150601.GK4405@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/14 16:06, Paul E. McKenney wrote:
> On Thu, Mar 20, 2014 at 03:58:52PM +0100, Arend van Spriel wrote:
>> On 20/03/14 15:37, Monam Agarwal wrote:
>>> This patchset uses following coccinelle script to replace
>>> rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
>>>
>>> @@
>>> expression E;
>>> @@
>>> - rcu_assign_pointer(
>>> + RCU_INIT_POINTER(
>>> E, NULL)
>>
>> I am not very familiar with rcu functionality nor coccinelle, but it
>> looks too generic. I would think only NULL assignments during
>> initialization should use RCU_INIT_POINTER(). The first patch in the
>> series does it in a function called unregister_...(). Is it really
>> ok to do there?
>
> Hello, Arend,
>
> The thing that rcu_assign_pointer() is doing is ensuring that the
> initialization of a structure is carried out before storing a pointer
> to that structure.  In the case of the NULL pointer, there is no
> structure to initialize, so nothing need be ordered.
>
> So, yes, rcu_assign_pointer(p, NULL) can always safely be converted to
> RCU_INIT_POINTER(p, NULL).  ;-)

And so I learned something today. Thanks, Paul. I really should pick up 
reading rcu material again. It ended up in a dusty corner upstairs.

Thanks,
Arend
