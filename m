From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [2.6.0-test-9] natsemi oops
Date: Tue, 28 Oct 2003 19:26:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F9EB4CE.2080308@colorfullife.com>
References: <20031028040421.98826.qmail@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Liontooth <liontooth@post.com>
In-Reply-To: <20031028040421.98826.qmail@mail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[netdev added to cc list: it looks like a module refcount bug with ipx]

David Liontooth wrote:

>The natsemi oops is triggered in 2.6.0-test9 too. 
>
>kernel BUG at include/linux/module.h:296
>  
>
That's BUG_ON(module_refcount(module) == 0) in __module_get. I doubt 
that the natsemi driver has anything to do with the bug, it looks like a 
bug in the ipx core.

>Everything freezes. 
>
>Am I the only one to get this? 
>
>I don't know when it started, but 2.5.69 has no problems.
>  
>
My guess: 2.5.69 has no bug check. It will oops with the right timing of 
rmmod and a packet arrival.

>Cheers,
>David
>
>
>----- Original Message -----
>From: "David Liontooth" <liontooth@post.com>
>Date: Mon, 20 Oct 2003 21:05:13 -0500
>To: linux-kernel@vger.kernel.org
>Subject: Re: [2.6.0-test-7] natsemi oops
>
>  
>
>>Correction: I get the oops also when natsemi is compiled as a module. 
>>It is triggered not when the module is loaded, but when it is used 
>>the first time. Oops (some fragments below) followed by a total freeze;
>>nothing gets logged.
>>
>>Is this a known problem? 
>>
>>Is there a workaround?
>>
>>Cheers,
>>David
>>
>>
>>----- Original Message -----
>>From: David Liontooth
>>Date: Mon, 20 Oct 2003 05:24:52 -0500
>>To: linux-kernel@vger.kernel.org
>>Subject: [2.6.0-test-7] natsemi oops
>>
>>    
>>
>>>The 2.6.0-test-7 boots fine and works great -- until I plug
>>>in the ethernet cable. Within a second I get an oops and
>>>everything freezes. Booting with "acpi=off" makes no difference.
>>>If I boot with the ethernet cable plugged in, I get to the 
>>>login prompt, and it oopses within a second. If I time it right,
>>>I can log into the machine remotely for one second before it 
>>>oopses (so the natsemi driver is working). Very reproducible! 
>>>/proc/kmsg is empty. 
>>>
>>>If I compile natsemi as a module, I don't get the oops. 
>>>However, now the driver is not working -- I can't ping out.
>>>Everything works fine in 2.5.69, which I've been running
>>>since early July.
>>>
>>>Here's some of the oops, taken by hand:
>>>
>>>Process swapper (pid: 0, threadinfo=c042a000 task c03a47a0)
>>>
>>>Stack
>>>
>>>Call trace:
>>>
>>>ipxitf_auto_create
>>>ipx_rcv
>>>netif_receive_skb
>>>process_backlog
>>>net_rx_action
>>>do_softirq
>>>do_IRQ
>>>_stext
>>>common_interrupt
>>>acpi_processor_idle
>>>cpu_idle
>>>start_kernel
>>>unknown_bootoption
>>>
>>>Kernel panic: Fatal exception in interrupt
>>>In interrupt handler -- not syncing
>>>
>>>Configuration, lspci, and dmesg attached.
>>>
>>>Cheers,
>>>David
>>>
>>>
>>>
>>>      
>>>
>><< config-2.6.0-test7-3 >>
>><< dmesg-2.6.0-test7-7 >>
>><< lspci-2.6.0-test7 >>
>>
>>-- 
>>__________________________________________________________
>>Sign-up for your own personalized E-mail at Mail.com
>>http://www.mail.com/?sr=signup
>>
>>CareerBuilder.com has over 400,000 jobs. Be smarter about your job search
>>http://corp.mail.com/careers
>>
>>    
>>
>
>  
>

--
    Manfred
