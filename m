From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 22:36:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87E6B4.80304@mandrakesoft.com>
References: <3D87A4A2.6050403@mandrakesoft.com>	<20020917.144911.43656989.davem@redhat.com>	<3D87E0C2.6040004@mandrakesoft.com> <20020917.190641.84134530.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@mandrakesoft.com>
>    Date: Tue, 17 Sep 2002 22:11:14 -0400
>    
>    You're looking at at least one extra get-irq-status too, at least in the 
>    classical 10/100 drivers I'm used to seeing...
>    
> How so?  The number of ones done in the e1000 NAPI code are the same
> (read register until no interesting status bits remain set, same as
> pre-NAPI e1000 driver).
> 
> For tg3 it's a cheap memory read from the status block not a PIO.


Non-NAPI:

	get-irq-stat
	ack-irq
	get-irq-stat (omit, if no work loop)

NAPI:

	get-irq-stat
	ack-all-but-rx-irq
	mask-rx-irqs
	get-irq-stat (omit, if work loop)
	...
	ack-rx-irqs
	get-irq-stat
	unmask-rx-irqs

This is the low load / low latency case only.  The number of IOs 
decreases at higher loads [obviously :)]
