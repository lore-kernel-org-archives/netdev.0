From: "ravinandan arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Submission for S2io 10GbE driver
Date: Thu, 19 Feb 2004 18:59:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002e01c3f75d$a1413410$8e10100a@S2IOtech.com>
References: <403573B5.4050100@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <raghavendra.koushik@wipro.com>, <leonid.grossman@s2io.com>,
        <netdev@oss.sgi.com>, <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <403573B5.4050100@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
Since the whole nic structure is zeroed out initially, the
"block_virt_addr" is initially NULL. So, if the allocation
succeeds, it will hold a non-NULL value.
So, in the freeSharedMem() if we check for it's non-NULL
value and free it, we should be okay. Do you agree ?

Thanks,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Thursday, February 19, 2004 6:41 PM
To: ravinandan arakali
Cc: raghavendra.koushik@wipro.com; leonid.grossman@s2io.com;
netdev@oss.sgi.com; raghavendra.koushik@s2io.com
Subject: Re: Submission for S2io 10GbE driver

ravinandan arakali wrote:
> Hi Jeff,
> For #7, the temporary variable tmp_v_addr is assigned as follows
> (immediately below the code you have quoted):
> 
> nic->rx_blocks[i][j].block_virt_addr = tmp_v_addr;

Yes... but only after the allocation.


> In the freeSharedMem() routine, we go thru' each block of each
> receive ring and free it. Following is the relevant piece of
> code:
> for (i = 0; i < config->RxRingNum; i++) {
>      blk_cnt = nic->block_count[i];
>      for (j = 0; j < blk_cnt; j++) {
>           tmp_v_addr = nic->rx_blocks[i][j].block_virt_addr;
>           tmp_p_addr = nic->rx_blocks[i][j].block_dma_addr;
>           pci_free_consistent(nic->pdev, size, tmp_v_addr,
tmp_p_addr);
>      }
> }
> 
> But I guess in the above piece of code, it may be a good idea to
> check if nic->rx_blocks[i][j].block_virt_addr is non-NULL before
> doing the pci_free_consistent().

Yes, you could add the check there.

	Jeff
