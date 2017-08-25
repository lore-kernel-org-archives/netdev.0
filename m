From: Anton Volkov <avolkov@ispras.ru>
Subject: Possible race in nsc-ircc.ko
Date: Fri, 25 Aug 2017 17:05:25 +0300
Message-ID: <4a33a281-f8bd-305b-e580-0e594feea799@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org,
        Alexey Khoroshilov <khoroshilov@ispras.ru>
To: dagb@cs.uit.no, jt@hpl.hp.com, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

While searching for races in the Linux kernel I've come across 
"drivers/net/irda/nsc-ircc.ko" module. Here is a question that I came up 
with while analyzing results. Lines are given using the info from Linux 
v4.12.

Consider the following case:

Thread 1:                   Thread 2:
nsc_ircc_init
->nsc_ircc_open
     self = netdev_priv(dev)
     register_netdev(dev)
                             nsc_ircc_net_ioctl
                             ->nsc_ircc_change_speed
     self->dongle_id = ...       <READ self->io.dongle_id>
     (nsc-ircc.c: line 485)      (nsc-ircc.c: line 1318)
     platform_device_register_simple

Before the initialization of self->dongle_id in msc_ircc_open() its 
value is 0. Thus if read access to its value in nsc_ircc_change_speed 
occurs before the initialization there will be an attempt to change 
speed of dongle with undesired id (if the dongle with id 0 exists). Is 
this case feasible from your point of view?

Thank you for your time.

-- Anton Volkov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: avolkov@ispras.ru
