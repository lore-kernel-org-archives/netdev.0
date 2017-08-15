From: Anton Volkov <avolkov@ispras.ru>
Subject: Possible race in via-ircc.ko
Date: Tue, 15 Aug 2017 17:11:57 +0300
Message-ID: <fa762133-a4d2-93ea-4ce9-24efbc067595@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org,
        Alexey Khoroshilov <khoroshilov@ispras.ru>
To: samuel@sortiz.org, sda@bdit.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

While searching for races in the Linux kernel I've come across 
"drivers/net/irda/via-ircc.ko" module. Here are questions that I came up 
with while analyzing results. Lines are given using the info from Linux 
v4.12.

Consider the following case:

Thread 1:                Thread 2:
via_ircc_net_open
   request_irq
   <turn on interrupts>
                          via_ircc_interrupt
-> via_ircc_dma_receive  -> RxTimerHandler
    (via-ircc.c: line 1488)  (via-ircc.c: line 1315)
      self->... = ...          ... = self->...

In the via_ircc_dma_receive a lot of fields of 'self' structure are 
initialized and via_ircc_interrupt with RxTimerHandler use those fields. 
If no initialization happened interrupt handler and other functions that 
it calls may work with incorrect data. I'm not sure how bad this case 
can be and thus here are my questions. Is this situation feasible from 
your point of view? If it is feasible, is it a benign race or something 
serious?

Thank you for your time.

-- Anton Volkov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: avolkov@ispras.ru
