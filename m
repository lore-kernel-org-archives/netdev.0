From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v4] ovs: limit ovs recursions in ovs_execute_actions
 to not corrupt stack
Date: Mon, 18 Jan 2016 12:21:16 +0100
Message-ID: <569CCAAC.6060906@stressinduktion.org>
References: <1452876675-19834-1-git-send-email-hannes@stressinduktion.org>
 <CAOrHB_BCZRG8NinFintTcaRd0MBsYPt-hAH9LG+6uNwOa0GQaA@mail.gmail.com>
 <20160117.192628.1780434341967114696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>, pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54674 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754273AbcARLVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 06:21:18 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 35EE12051A
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 06:21:18 -0500 (EST)
In-Reply-To: <20160117.192628.1780434341967114696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.01.2016 01:26, David Miller wrote:
> From: pravin shelar <pshelar@ovn.org>
> Date: Sat, 16 Jan 2016 09:04:50 -0800
>
>> This function always run in soft-irq context. Do we really need this
>> preempt-disable call here?
>
> Hannes, please respond to this feedback.

Sorry, was traveling on the weekend.

Pravin, I added preempt protection because of the discussion about this 
patch: <http://www.spinics.net/lists/linux-rt-users/msg14343.html>

I didn't want to add a recursion limiter into struct task_struct for 
ovs, so I disable preemption here. On non-rt kernels this will have no 
change in behavior (besides the accesses to the preempt counter), but it 
does the right thing on -rt kernels.

I don't think that -rt kernels are important for openvswitch right now, 
so this is just a safe guard.

Bye,
Hannes
