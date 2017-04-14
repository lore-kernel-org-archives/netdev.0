From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 01/22] scatterlist: Introduce sg_map helper functions
Date: Fri, 14 Apr 2017 09:34:28 -0600
Message-ID: <18f05078-5b2c-2e9b-c8ad-e23c02942b58@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-2-git-send-email-logang@deltatee.com>
 <20170414083518.GA25471@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Tejun Heo <tj@k
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <20170414083518.GA25471-jcswGhMUV9g@public.gmane.org>
List-Unsubscribe: <https://lists.01.org/mailman/options/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.01.org/pipermail/linux-nvdimm/>
List-Post: <mailto:linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Help: <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.01.org/mailman/listinfo/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=subscribe>
Errors-To: linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Sender: "Linux-nvdimm" <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Id: netdev.vger.kernel.org



On 14/04/17 02:35 AM, Christoph Hellwig wrote:
>> +
>>  static inline int is_dma_buf_file(struct file *);
>>  
>>  struct dma_buf_list {
> 
> I think the right fix here is to rename the operation to unmap_atomic
> and send out a little patch for that ASAP.

Ok, I can do that next week.

> I'd rather have separate functions for kmap vs kmap_atomic instead of
> the flags parameter.  And while you're at it just always pass the 0
> offset parameter instead of adding a wrapper..
> 
> Otherwise this looks good to me.

I settled on the flags because I thought the interface could be expanded
to do more things like automatically copy iomem to a bounce buffer (with
a flag). It'd also be possible to add things like vmap and
physical_address to the interface which would cover even more sg_page
users. All the implementations would then share the common offset
calculations, and switching between them becomes a matter of changing a
couple flags.

If you're still not convinced by the above arguments  then I'll change
it but I did have reasons for choosing to do it this way.

I am fine with removing the offset versions. I will make that change.

Thanks,

Logan
