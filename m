From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VMXNET3: Add support for virtual IOMMU
Date: Wed, 21 Aug 2013 00:02:55 -0700 (PDT)
Message-ID: <20130821.000255.1258155583733908892.davem@davemloft.net>
References: <1377020012-1839-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: acking@vmware.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1377020012-1839-1-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Andy King <acking@vmware.com>
Date: Tue, 20 Aug 2013 10:33:32 -0700

> We can't just do virt_to_phys() on memory that we pass to the device and
> expect it to work in presence of a virtual IOMMU.  We need to add IOMMU
> mappings for such DMAs to work correctly.  Fix that with
> pci_alloc_consistent() where possible, or pci_map_single() where the
> mapping is short-lived or we don't control the allocation (netdev).
> 
> Also fix two small bugs:
> 1) use after free of rq->buf_info in vmxnet3_rq_destroy()
> 2) a cpu_to_le32() that should have been a cpu_to_le64()
> 
> Acked-by: George Zhang <georgezhang@vmware.com>
> Acked-by: Aditya Sarwade <asarwade@vmware.com>
> Signed-off-by: Andy King <acking@vmware.com>

Please use dma_alloc_coherent() (or in fact dma_zalloc_coherent()),
dma_map_single() et al., because they are preferred and in particular
allow specification of GFP_* flags.
