From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: panic in tg3 driver
Date: Wed, 13 Apr 2011 14:23:41 -0400
Message-ID: <4DA5EA2D.8010207@earthlink.net>
References: <4D2334B5.1060408@earthlink.net> <4D2A371A.40103@earthlink.net> <20110110192216.GA23741@mcarlson.broadcom.com> <4D2B6652.7040607@earthlink.net> <20110111020055.GA25351@mcarlson.broadcom.com> <4D2C64EF.1080905@earthlink.net> <20110112030652.GA27164@mcarlson.broadcom.com> <4D2EFA44.8080008@earthlink.net> <4D3334E6.40100@earthlink.net> <20110125005922.GA19701@mcarlson.broadcom.com> <20110125022532.GA19884@mcarlson.broadcom.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:39265 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751801Ab1DMSXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:23:45 -0400
In-Reply-To: <20110125022532.GA19884@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2011 09:25 PM, Matt Carlson wrote:
> On Mon, Jan 24, 2011 at 04:59:22PM -0800, Matt Carlson wrote:
>    
>> On Sun, Jan 16, 2011 at 10:11:50AM -0800, Stephen Clark wrote:
>>      
>>> On 01/13/2011 08:12 AM, Stephen Clark wrote:
>>>        
>>>> On 01/11/2011 10:06 PM, Matt Carlson wrote:
>>>>          
>>>>> lspci -vvv -xxx -s 81:00.0
>>>>>            
>>>>
>>>>
>>>> Further information - I found these messages in /var/log/messages. It
>>>> looks
>>>> like after it switched to INTx mode interrupts for other devices were
>>>> hosed.
>>>>
>>>> Jan 12 08:37:49 localhost kernel: tg3 0000:81:00.0: eth2: No interrupt
>>>> was gener
>>>> ated using MSI. Switching to INTx mode. Please report this failure to
>>>> the PCI ma
>>>> intainer and include system chipset information
>>>> Jan 12 08:37:49 localhost kernel: ADDRCONF(NETDEV_UP): eth2: link is
>>>> not ready
>>>> Jan 12 08:38:50 localhost kernel: ata2: lost interrupt (Status 0x50)
>>>> Jan 12 08:38:50 localhost kernel: ata2.01: exception Emask 0x0 SAct
>>>> 0x0 SErr 0x0
>>>>   action 0x6 frozen
>>>> Jan 12 08:38:50 localhost kernel: ata2.01: failed command: WRITE DMA
>>>> Jan 12 08:38:50 localhost kernel: ata2.01: cmd
>>>> ca/00:08:e0:bc:51/00:00:00:00:00/f0 tag 0 dma 4096 out
>>>> Jan 12 08:38:50 localhost kernel:          res
>>>> 40/00:01:00:4f:c2/00:00:00:00:00/b0 Emask 0x4 (timeout)
>>>> Jan 12 08:38:50 localhost kernel: ata2.01: status: { DRDY }
>>>> Jan 12 08:38:50 localhost kernel: ata2: soft resetting link
>>>> Jan 12 08:38:50 localhost kernel: do_IRQ: 0.64 No irq handler for
>>>> vector (irq -1)
>>>> Jan 12 08:38:50 localhost kernel: ata2.01: configured for UDMA/33
>>>> Jan 12 08:38:54 localhost pppd[1983]: No response to 3 echo-requests
>>>> Jan 12 08:39:55 localhost pppoe[1988]: Inactivity timeout... something
>>>> wicked happened on session 3363
>>>>          
>>> Just checking to make sure you have everything you need?
>>>        
>> Sorry for the delay Stephen.
>>
>> It looks to me like interrupts aren't being setup correctly on this
>> system.  I tested MSI and INTx interrupt modes locally and they both
>> work.  I'm guessing one of two things could be happening:
>>
>> 1) The 2nd parameter of the low-level ISR (tg3_interrupt_tagged()) is
>>     not correct.  The ISR tries to tell the hardware the interrupt is
>>     acknowledged, but the message goes unheard.  (This might also explain
>>     why other devices are also afflicted.)
>>
>> 2) Something is blocking the delivery of the interrupt to the tg3 driver
>>     altogether.
>>
>> In both cases, the hardware persistently nags the host to ack the
>> interrupt, hence the interrupt storm.
>>      
> Just curious, is the problem still there if you add pci=nomsi to the
> kernel command line?
>
>    
Sorry I have been tied up.

With kernel 2.6.32-44.1.el6.i686 and pci=nomsi on the kernel command 
line it seems to work great.

[root@Z1010 ~]# ping -f 3.3.3.2
PING 3.3.3.2 (3.3.3.2) 56(84) bytes of data.
.^
--- 3.3.3.2 ping statistics ---
20562 packets transmitted, 20562 received, 0% packet loss, time 4408ms
rtt min/avg/max/mdev = 0.141/0.163/1.021/0.034 ms, ipg/ewma 0.214/0.161 ms



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>    


-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



