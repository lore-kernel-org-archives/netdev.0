From: Harsh Jain <harshjain.prof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 08/22] crypto: chcr: Make use of the new sg_map helper
 function
Date: Sat, 15 Apr 2017 10:23:33 +0530
Message-ID: <CAFXBA=k74+9jRZQX4r_iGoL8yiDbXPDTLw+AELEb1LeT_jeKiQ@mail.gmail.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-9-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
 fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>,
 intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org,
 linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
 linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev@
To: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>, harsh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <1492121135-4437-9-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
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

On Fri, Apr 14, 2017 at 3:35 AM, Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org> wrote:
> The get_page in this area looks *highly* suspect due to there being no
> corresponding put_page. However, I've left that as is to avoid breaking
> things.
chcr driver will post the request to LLD driver cxgb4 and put_page is
implemented there. it will no harm. Any how
we have removed the below code from driver.

http://www.mail-archive.com/linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg24561.html

After this merge we can ignore your patch. Thanks

>
> I've also removed the KMAP_ATOMIC_ARGS check as it appears to be dead
> code that dates back to when it was first committed...


>
> Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/crypto/chelsio/chcr_algo.c | 28 +++++++++++++++-------------
>  1 file changed, 15 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
> index 41bc7f4..a993d1d 100644
> --- a/drivers/crypto/chelsio/chcr_algo.c
> +++ b/drivers/crypto/chelsio/chcr_algo.c
> @@ -1489,22 +1489,21 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
>         return ERR_PTR(-EINVAL);
>  }
>
> -static void aes_gcm_empty_pld_pad(struct scatterlist *sg,
> -                                 unsigned short offset)
> +static int aes_gcm_empty_pld_pad(struct scatterlist *sg,
> +                                unsigned short offset)
>  {
> -       struct page *spage;
>         unsigned char *addr;
>
> -       spage = sg_page(sg);
> -       get_page(spage); /* so that it is not freed by NIC */
> -#ifdef KMAP_ATOMIC_ARGS
> -       addr = kmap_atomic(spage, KM_SOFTIRQ0);
> -#else
> -       addr = kmap_atomic(spage);
> -#endif
> -       memset(addr + sg->offset, 0, offset + 1);
> +       get_page(sg_page(sg)); /* so that it is not freed by NIC */
> +
> +       addr = sg_map(sg, SG_KMAP_ATOMIC);
> +       if (IS_ERR(addr))
> +               return PTR_ERR(addr);
> +
> +       memset(addr, 0, offset + 1);
> +       sg_unmap(sg, addr, SG_KMAP_ATOMIC);
>
> -       kunmap_atomic(addr);
> +       return 0;
>  }
>
>  static int set_msg_len(u8 *block, unsigned int msglen, int csize)
> @@ -1940,7 +1939,10 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
>         if (req->cryptlen) {
>                 write_sg_to_skb(skb, &frags, src, req->cryptlen);
>         } else {
> -               aes_gcm_empty_pld_pad(req->dst, authsize - 1);
> +               err = aes_gcm_empty_pld_pad(req->dst, authsize - 1);
> +               if (err)
> +                       goto dstmap_fail;
> +
>                 write_sg_to_skb(skb, &frags, reqctx->dst, crypt_len);
>
>         }
> --
> 2.1.4
>
