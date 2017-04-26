From: Roger Pau =?iso-8859-1?Q?Monn=E9?= <roger.pau-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 15/21] xen-blkfront: Make use of the new sg_map helper
 function
Date: Wed, 26 Apr 2017 08:37:20 +0100
Message-ID: <20170426073720.okv33ly2ldepilti@dhcp-3-128.uk.xensource.com>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com>
 <1493144468-22493-16-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
 devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Juergen Gross <jgross-IBi9RG/b67k@public.gmane.org>, Julien Grall <julien.grall-5wv7dgnIgG8@public.gmane.org>,
 intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org,
 linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Greg Kroah-Hartman <gregkh@linuxfounda
To: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1493144468-22493-16-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
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

On Tue, Apr 25, 2017 at 12:21:02PM -0600, Logan Gunthorpe wrote:
> Straightforward conversion to the new helper, except due to the lack
> of error path, we have to use SG_MAP_MUST_NOT_FAIL which may BUG_ON in
> certain cases in the future.
> =

> Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
> Cc: Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Juergen Gross <jgross-IBi9RG/b67k@public.gmane.org>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: "Roger Pau Monn=E9" <roger.pau-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/block/xen-blkfront.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
> =

> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> index 3945963..ed62175 100644
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -816,8 +816,9 @@ static int blkif_queue_rw_req(struct request *req, st=
ruct blkfront_ring_info *ri
>  		BUG_ON(sg->offset + sg->length > PAGE_SIZE);
>  =

>  		if (setup.need_copy) {
> -			setup.bvec_off =3D sg->offset;
> -			setup.bvec_data =3D kmap_atomic(sg_page(sg));
> +			setup.bvec_off =3D 0;
> +			setup.bvec_data =3D sg_map(sg, 0, SG_KMAP_ATOMIC |
> +						 SG_MAP_MUST_NOT_FAIL);

I assume that sg_map already adds sg->offset to the address?

Also wondering whether we can get rid of bvec_off and just increment bvec_d=
ata,
adding Julien who IIRC added this code.

>  		}
>  =

>  		gnttab_foreach_grant_in_range(sg_page(sg),
> @@ -827,7 +828,7 @@ static int blkif_queue_rw_req(struct request *req, st=
ruct blkfront_ring_info *ri
>  					      &setup);
>  =

>  		if (setup.need_copy)
> -			kunmap_atomic(setup.bvec_data);
> +			sg_unmap(sg, setup.bvec_data, 0, SG_KMAP_ATOMIC);
>  	}
>  	if (setup.segments)
>  		kunmap_atomic(setup.segments);
> @@ -1053,7 +1054,7 @@ static int xen_translate_vdev(int vdevice, int *min=
or, unsigned int *offset)
>  		case XEN_SCSI_DISK5_MAJOR:
>  		case XEN_SCSI_DISK6_MAJOR:
>  		case XEN_SCSI_DISK7_MAJOR:
> -			*offset =3D (*minor / PARTS_PER_DISK) + =

> +			*offset =3D (*minor / PARTS_PER_DISK) +
>  				((major - XEN_SCSI_DISK1_MAJOR + 1) * 16) +
>  				EMULATED_SD_DISK_NAME_OFFSET;
>  			*minor =3D *minor +
> @@ -1068,7 +1069,7 @@ static int xen_translate_vdev(int vdevice, int *min=
or, unsigned int *offset)
>  		case XEN_SCSI_DISK13_MAJOR:
>  		case XEN_SCSI_DISK14_MAJOR:
>  		case XEN_SCSI_DISK15_MAJOR:
> -			*offset =3D (*minor / PARTS_PER_DISK) + =

> +			*offset =3D (*minor / PARTS_PER_DISK) +
>  				((major - XEN_SCSI_DISK8_MAJOR + 8) * 16) +
>  				EMULATED_SD_DISK_NAME_OFFSET;
>  			*minor =3D *minor +
> @@ -1119,7 +1120,7 @@ static int xlvbd_alloc_gendisk(blkif_sector_t capac=
ity,
>  	if (!VDEV_IS_EXTENDED(info->vdevice)) {
>  		err =3D xen_translate_vdev(info->vdevice, &minor, &offset);
>  		if (err)
> -			return err;		=

> +			return err;

Cosmetic changes should go in a separate patch please.

Roger.
