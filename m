From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/4] net: ethernet: ti: cpts: fix tx timestamping
 timeout
Date: Tue, 01 Aug 2017 15:24:48 -0700 (PDT)
Message-ID: <20170801.152448.1138483934474397257.davem@davemloft.net>
References: <20170728223005.21420-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        w-kwok2@ti.com, ivan.khoronzhuk@linaro.org, john.stultz@linaro.org,
        tglx@linutronix.de
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728223005.21420-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Fri, 28 Jul 2017 17:30:01 -0500

> With the low Ethernet connection speed cpdma notification about packet
> processing can be received before CPTS TX timestamp event, which is set
> when packet actually left CPSW while cpdma notification is sent when packet
> pushed in CPSW fifo. As result, when connection is slow and CPU is fast
> enough TX timestamping is not working properly.
> Issue was discovered using timestamping tool on am57x boards with Ethernet link
> speed forced to 100M and on am335x-evm with Ethernet link speed forced to 10M.
> 
> Patch3 - This series fixes it by introducing TX SKB queue to store PTP SKBs for
> which Ethernet Transmit Event hasn't been received yet and then re-check this
> queue with new Ethernet Transmit Events by scheduling CPTS overflow
> work more often until TX SKB queue is not empty.
> 
> Patch 1,2 - As CPTS overflow work is time critical task it important to ensure
> that its scheduling is not delayed. Unfortunately, There could be significant
> delay in CPTS work schedule under high system load and on -RT which could cause
> CPTS misbehavior due to internal counter overflow and there is no way to tune
> CPTS overflow work execution policy and priority manually. The kthread_worker
> can be used instead of workqueues, as it creates separate named kthread for
> each worker and its its execution policy and priority can be configured
> using chrt tool. Instead of modifying CPTS driver itself it was proposed to
> it was proposed to add PTP auxiliary worker to the PHC subsystem [1], so
> other drivers can benefit from this feature also.
> 
> [1] https://www.spinics.net/lists/netdev/msg445392.html

Series applied to 'net', thanks.
