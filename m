From: Pavel Andrianov <andrianov@ispras.ru>
Subject: A potential race in drivers/atm/eni.ko
Date: Mon, 8 Aug 2016 11:17:00 +0300
Message-ID: <3f46f924-29e9-a8f9-c9e7-531cb6dc0765@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vaishali Thakkar <vaishali.thakkar@oracle.com>,
	ldv-project@linuxtesting.org
To: Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

There is a potential race in drivers/atm/eni.ko.

In the interrupt handler eni_int the field eni_dev->events is masked 
(line 1519) with a spinlock protection. In eni_start eni_dev->events is 
initialized (line 1844), but it is done after interrupts are requested 
(line 1813). Thus, the interrupt may occur while initialization is not 
finishing and the new value of events will be lost. Moreover, the 
spinlock, which is used in the interrupt handler, is also initialized 
(line 1842) after request_irq (line 1813).

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru
