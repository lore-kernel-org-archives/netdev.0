From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Extend irq_set_affinity_notifier() to use  a call chain
Date: Sun, 25 May 2014 15:15:24 +0300
Message-ID: <5381DEDC.8050204@gmail.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, idos@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Thomas Gleixner <tglx@linutronix.de>,
	Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm working for Mellanox on mlx4_en NIC driver.

We need to be able to be notified on irq affinity changes.
This is because, during non-stop full bandwidth traffic, napi will poll 
constantly and no interrupt will be fired. Because of that, even if the 
user changes the irq affinity, polling will continue to be done on the 
original CPU that was chosen on the first packet.
We would like to be notified when the affinity is changed. When such an 
event happen, the driver will arm the interrupts and end the napi 
session. An interrupt will start a new napi session on the right CPU.

In order to do that, I need to add a new irq affinity notification 
callback (In addition to the existing cpu_rmap notification). For that I 
would like to extend irq_set_affinity_notifier() to have a notifier 
call-chain instead of a single notifier callback.

I wanted to hear your opinion on this, and unless there is a better 
solution, will send an RFC later on.

References:
- http://patchwork.ozlabs.org/patch/65244/ - Review done by Thomas 
Glexiber to Ben Hutchings first version of the irq affinity notifiers.
- http://patchwork.ozlabs.org/patch/79593/ - Final version of 
irq_set_affinity_notifier() that was applied

Thanks,
Amir
