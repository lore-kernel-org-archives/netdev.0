From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Mon, 19 Jul 2004 18:29:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <85DC52B0-D9DB-11D8-AE55-000393C30512@freescale.com>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <2A724364-D53A-11D8-8835-000393C30512@freescale.com> <40F4A6E5.4060000@pobox.com>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <AFLEMING@motorola.com>, <netdev@oss.sgi.com>,
        Kumar Gala <kumar.gala@motorola.com>, <hadi@cyberus.ca>,
        <dwmw2@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <40F4A6E5.4060000@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Jul 13, 2004, at 22:22, Jeff Garzik wrote:

> Andy Fleming wrote:
>> Ok, I've got the new PHY code working, and I've done most of the 
>> changes, but I have a couple more questions:
>>>>
>>>> 6) sysfs support:  call SET_NETDEV_DEV()
>> Ok, the first argument should be dev, but what should the second 
>> argument be?  This isn't a PCI device, it's
>> an on-chip peripheral, so I'm not sure what the class_device should 
>> be.
>
> It's a struct device, which all devices need to have.
>
> I could have sworn OCP does struct device these days.  If not, poke 
> the platform people.

Ah, I found it.  ocpdev->dev.  Done.

>
>
>>>> 19) I think your gfar_poll() needs spin_lock_irqsave(), not 
>>>> spin_lock().
>> Hmm... I tried that, but netif_receive_skb() will eventually call 
>> local_bh_enable(), which dislikes my disabling interrupts.  I could 
>> avoid this by unlocking around netif_receive_skb(), but this solution 
>> seems ugly to me.  What is the preferred way of doing this?
>
> Duh.  I had a brainfart.
>
> RX "synchronization" is normally done by simply ensuring that no other 
> code will cause a NAPI poll.  You shouldn't need spinlocks around that 
> section of code at all.  Take a look at drivers/net/tg3.c, tg3_rx()

Ok.  I will send a new patch tomorrow.

>
> 	Jeff
