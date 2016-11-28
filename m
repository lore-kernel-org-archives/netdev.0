From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net, sched: respect rcu grace period on cls destruction
Date: Mon, 28 Nov 2016 11:51:12 +0100
Message-ID: <583C0C20.3020703@iogearbox.net>
References: <0d6d89f885033f1739e97f7f3372ae6e1db72892.1480204343.git.daniel@iogearbox.net> <CAM_iQpVRDnLM_Cmp63PVkpYtmdtNECP-2m89=DGdidkUYyHwug@mail.gmail.com> <583BF43C.4020103@iogearbox.net> <20161128104736.GX31360@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Roi Dayan <roid@mellanox.com>, ast@fb.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42283 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbcK1KvZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 05:51:25 -0500
In-Reply-To: <20161128104736.GX31360@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 11:47 AM, Paul E. McKenney wrote:
> On Mon, Nov 28, 2016 at 10:09:16AM +0100, Daniel Borkmann wrote:
>> On 11/28/2016 07:57 AM, Cong Wang wrote:
[...]
>>> The ugly part is the work struct, I am not an RCU expert so don't know if we
>>> have any API to execute an RCU callback in process context. Paul?
>>
>> Same way we do this in BPF with prog destruction, by the way. I'm not aware
>> of any callback API for RCU that lets you do this, but maybe Paul knows.
>
> RCU callbacks are always executed in softirq context, so yes, you do need
> to use something like a work struct.  (Or a wakeup to a kthread or
> whatever.)

Ok, thanks for the confirmation!

Daniel
