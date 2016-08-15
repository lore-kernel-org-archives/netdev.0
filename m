From: Pavel Andrianov <andrianov@ispras.ru>
Subject: A potential data race in drivers/isdn/hardware/eicon/diva_mnt.ko
Date: Mon, 15 Aug 2016 17:06:51 +0300
Message-ID: <b5d9c5f8-7f52-c499-c5fa-68f72d88f38f@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vaishali Thakkar <vaishali.thakkar@oracle.com>,
	ldv-project@linuxtesting.org
To: mac@melware.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

There is a potential data race in drivers/isdn/hardware/eicon/diva_mnt.ko

In diva_maint_init there is an initialization of spinlocks (debug.c: 
lines 245, 252) and a queue (debug.c: line 237). These objects are used 
in handlers of divas_main_fops, for instance, divas_maint_read. These 
ops are registered in divas_maint_register_chrdev, which is called 
(divamnt.c: line 206) before initialization (divamnt.c: line 211). Thus, 
there may occur a situation when the handlers of divas_main_fops occur 
to uninitialized resources.

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru
