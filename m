From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cnic: call cp->stop_hw() in cnic_start_hw()
 on allocation failure
Date: Fri, 06 May 2016 15:45:29 -0400 (EDT)
Message-ID: <20160506.154529.2181132233503341654.davem@davemloft.net>
References: <1462406151-5224-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmaxwell@redhat.com, ivecera@redhat.com
To: jmaxwell37@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462406151-5224-1-git-send-email-jmaxwell37@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Maxwell <jmaxwell37@gmail.com>
Date: Thu,  5 May 2016 09:55:51 +1000

> We recently had a system crash in the cnic module. Vmcore analysis confirmed 
> that "ip link up" was executed which failed due to an allocation failure 
> because of memory fragmentation. Futher analysis revealed that the cnic irq 
> vector was still allocated after the "ip link up" that failed. When 
> "ip link down" was executed it called free_msi_irqs() which crashed the system 
> because the cnic irq was still inuse.
 ...
> The cnic_start_hw() routine is not handling the allocation failure correctly. 
> Fix this by checking whether CNIC_DRV_STATE_HANDLES_IRQ flag is set indicating 
> that the hardware has been started in cnic_start_hw(). If it has then call 
> cp->stop_hw() which frees the cnic irq vector and cnic resources. Otherwise 
> just maintain the previous behaviour and free cnic resources. 
> 
> I reproduced this by injecting an ENOMEM error into cnic_cm_alloc_mem()s return
> code. 
> 
> # ip link set dev enpX down
> # ip link set dev enpX up <--- hit's allocation failure
> # ip link set dev enpX down <--- crashes here
> 
> With this patch I confirmed there was no crash in the reproducer.
> 
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>

Applied, thank you.
