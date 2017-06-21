From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] netxen: Fix a sleep-in-atomic bug in netxen_nic_pci_mem_access_direct
Date: Wed, 21 Jun 2017 09:11:43 +0300
Message-ID: <87d19xooo0.fsf@purkki.adurom.net>
References: <1497840533-4894-1-git-send-email-baijiaju1990@163.com>
        <20170620.133530.1607963470682255531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: baijiaju1990@163.com, manish.chopra@cavium.com,
        rahul.verma@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620.133530.1607963470682255531.davem@davemloft.net> (David
        Miller's message of "Tue, 20 Jun 2017 13:35:30 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Jia-Ju Bai <baijiaju1990@163.com>
> Date: Mon, 19 Jun 2017 10:48:53 +0800
>
>> The driver may sleep under a spin lock, and the function call path is:
>> netxen_nic_pci_mem_access_direct (acquire the lock by spin_lock)
>>   ioremap --> may sleep
>> 
>> To fix it, the lock is released before "ioremap", and the lock is 
>> acquired again after this function.
>> 
>> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
>
> This style of change you are making is really starting to be a
> problem.
>
> You can't just drop locks like this, especially without explaining
> why it's ok, and why the mutual exclusion this code was trying to
> achieve is still going to be OK afterwards.
>
> In fact, I see zero analysis of the locking situation here, why
> it was needed in the first place, and why your change is OK in
> that context.
>
> Any locking change is delicate, and you must put the greatest of
> care and consideration into it.
>
> Just putting "unlock/lock" around the sleeping operation shows a
> very low level of consideration for the implications of the change
> you are making.
>
> This isn't like making whitespace fixes, sorry...

We already tried to explain this to Jia-Ju during review of a wireless
patch:

https://patchwork.kernel.org/patch/9756585/

Jia-Ju, you should listen to feedback. If you continue submitting random
patches like this makes it hard for maintainers to trust your patches
anymore.

-- 
Kalle Valo
