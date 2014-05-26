From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: Extend irq_set_affinity_notifier() to use a call chain
Date: Mon, 26 May 2014 14:24:34 +0300
Message-ID: <53832472.7070000@gmail.com>
References: <5381DEDC.8050204@gmail.com> <alpine.DEB.2.02.1405261313570.21720@ionos.tec.linutronix.de>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, idos@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1405261313570.21720@ionos.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/26/2014 2:15 PM, Thomas Gleixner wrote:
> On Sun, 25 May 2014, Amir Vadai wrote:
>> In order to do that, I need to add a new irq affinity notification
>> callback (In addition to the existing cpu_rmap notification). For
>> that I would like to extend irq_set_affinity_notifier() to have a
>> notifier call-chain instead of a single notifier callback.
>
> Why? "I would like" is a non argument.
Current implementation enables only one callback to be registered for 
irq affinity change notifications.

cpu_rmap is registered be notified - for RFS purposes.
mlx4_en (and probably other network drivers) needs to be notified too, 
in order to stop the napi polling on the old cpu and move to the new one.
To enable more than 1 notification callbacks, I suggest to use a 
notifier call chain.

Amir

>
> Thanks,
>
> 	tglx
>
