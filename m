From: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 02/16] IB/pvrdma: Add user-level shared functions
Date: Mon, 26 Sep 2016 10:33:08 -0700
Message-ID: <90c86f40-7a7d-4075-0c55-336d4f2ed443@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <b52db7f59d69089f7b1d53311574143c4da8252a.1474759181.git.aditr@vmware.com>
 <20160925072624.GV4088@leon.nu>
 <9c9f3668-ff2b-f421-2270-3193c0f62cc9@vmware.com>
 <20160926061338.GH4088@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160926061338.GH4088-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 25, 2016 at 23:13:38PM -0700, Leon Romanovsky wrote:
> On Sun, Sep 25, 2016 at 09:22:11PM -0700, Adit Ranadive wrote:
>> On Sun, Sep 25 2016 at 10:26:24AM +0300, Leon Romanovsky wrote:
> > > > On Sat, Sep 24, 2016 at 04:21:26PM -0700, Adit Ranadive wrote:
> > > > We share some common structures with the user-level driver. This patch adds
> > > > those structures and shared functions to traverse the QP/CQ rings.
> >
> > <...>
> >
> > > > +
> > > > +#include <linux/types.h>
> > > > +
> > > > +#define PVRDMA_UVERBS_ABI_VERSION	3
> > > > +#define PVRDMA_BOARD_ID			1
> > > > +#define PVRDMA_REV_ID			1
> > > >
> > > > Please don't add defines which you are not using in the library and the
> > > > two above are not in use.
> > > >
> >
> > I'll move these to the pvrdma.h file.
> >
> > <...>
> >
> > > > diff --git a/include/uapi/rdma/pvrdma-uapi.h b/include/uapi/rdma/pvrdma-uapi.h
> > > > new file mode 100644
> > > > index 0000000..430d8a5
> >
> > <...>
> >
> > > > +
> > > > +#ifndef __PVRDMA_UAPI_H__
> > > > +#define __PVRDMA_UAPI_H__
> > > > +
> > > > +#include <linux/types.h>
> > > > +
> > > > +#define PVRDMA_VERSION 17
> > > >
> > > > What do you plan to do with this VERSION?
> > > > How is it related to ABI?
> > > >
> >
> > Not related. This is only for the driver to know which APIs to support.
> > For example, an older driver would still be able to work with a newer
> > device. I can move this to pvrdma.h as well.
> >
> > To be honest, I thought I can move this file into the uapi folder since
> > the structures here are shared with the user-level library. Based on
> > your comments in this thread and the other ones, I think it makes sense
> > to move this file back to the pvrdma driver folder and rename it
> > (pvrdma_wqe.h?) to avoid confusion. There might still be some duplicate
> > code (especially the UAR offsets and WQE structs) here and in our
> > user-level library.
> >
> > Let me know if that makes sense.
> >
> > > > +
> > > > +#define PVRDMA_UAR_HANDLE_MASK	0x00FFFFFF	/* Bottom 24 bits. */
> > > > +#define PVRDMA_UAR_QP_OFFSET	0		/* Offset of QP doorbell. */
> > > > +#define PVRDMA_UAR_QP_SEND	BIT(30)		/* Send bit. */
> > > > +#define PVRDMA_UAR_QP_RECV	BIT(31)		/* Recv bit. */
> > > > +#define PVRDMA_UAR_CQ_OFFSET	4		/* Offset of CQ doorbell. */
> > > > +#define PVRDMA_UAR_CQ_ARM_SOL	BIT(29)		/* Arm solicited bit. */
> > > > +#define PVRDMA_UAR_CQ_ARM	BIT(30)		/* Arm bit. */
> > > > +#define PVRDMA_UAR_CQ_POLL	BIT(31)		/* Poll bit. */
> > > > +#define PVRDMA_INVALID_IDX	-1		/* Invalid index. */
> > > >
> > > > +
> > > > +/* PVRDMA atomic compare and swap */
> > > > +struct pvrdma_exp_cmp_swap {
> > > >
> > > > _EXP_ looks very similar to MLNX_OFED naming convention.
> > > >
> >
> > Yes, the operation was based on that. Any concerns?
> > I can rename this and the one below.
> 
> Yes, please.
> The common practice in IB subsystem is to use _ex_ notation for such
> extended structures.
> 

Ok.

> >
> > > > +	__u64 swap_val;
> > > > +	__u64 compare_val;
> > > > +	__u64 swap_mask;
> > > > +	__u64 compare_mask;
> > > > +};
> > > > +
> > > > +/* PVRDMA atomic fetch and add */
> > > > +struct pvrdma_exp_fetch_add {
> > > >
> > > > The same as above.
> > > >
> > > > +	__u64 add_val;
> > > > +	__u64 field_boundary;
> > > > +};
> > > > +
> > > > +/* PVRDMA address vector. */
> > > > +struct pvrdma_av {
> > > > +	__u32 port_pd;
> > > > +	__u32 sl_tclass_flowlabel;
> > > > +	__u8 dgid[16];
> > > > +	__u8 src_path_bits;
> > > > +	__u8 gid_index;
> > > > +	__u8 stat_rate;
> > > > +	__u8 hop_limit;
> > > > +	__u8 dmac[6];
> > > > +	__u8 reserved[6];
> > > > +};
> > > > +
> > > > +/* PVRDMA scatter/gather entry */
> > > > +struct pvrdma_sge {
> > > > +	__u64   addr;
> > > > +	__u32   length;
> > > > +	__u32   lkey;
> > > > +};
> > > > +
> > > > +/* PVRDMA receive queue work request */
> > > > +struct pvrdma_rq_wqe_hdr {
> > > > +	__u64 wr_id;		/* wr id */
> > > > +	__u32 num_sge;		/* size of s/g array */
> > > > +	__u32 total_len;	/* reserved */
> > > > +};
> > > > +/* Use pvrdma_sge (ib_sge) for receive queue s/g array elements. */
> > > > +
> > > > +/* PVRDMA send queue work request */
> > > > +struct pvrdma_sq_wqe_hdr {
> > > > +	__u64 wr_id;		/* wr id */
> > > > +	__u32 num_sge;		/* size of s/g array */
> > > > +	__u32 total_len;	/* reserved */
> > > > +	__u32 opcode;		/* operation type */
> > > > +	__u32 send_flags;	/* wr flags */
> > > > +	union {
> > > > +		__u32 imm_data;
> > > > +		__u32 invalidate_rkey;
> > > > +	} ex;
> > > > +	__u32 reserved;
> > > > +	union {
> > > > +		struct {
> > > > +			__u64 remote_addr;
> > > > +			__u32 rkey;
> > > > +			__u8 reserved[4];
> > > > +		} rdma;
> > > > +		struct {
> > > > +			__u64 remote_addr;
> > > > +			__u64 compare_add;
> > > > +			__u64 swap;
> > > > +			__u32 rkey;
> > > > +			__u32 reserved;
> > > > +		} atomic;
> > > > +		struct {
> > > > +			__u64 remote_addr;
> > > > +			__u32 log_arg_sz;
> > > > +			__u32 rkey;
> > > > +			union {
> > > > +				struct pvrdma_exp_cmp_swap  cmp_swap;
> > > > +				struct pvrdma_exp_fetch_add fetch_add;
> > > > +			} wr_data;
> > > > +		} masked_atomics;
> > > > +		struct {
> > > > +			__u64 iova_start;
> > > > +			__u64 pl_pdir_dma;
> > > > +			__u32 page_shift;
> > > > +			__u32 page_list_len;
> > > > +			__u32 length;
> > > > +			__u32 access_flags;
> > > > +			__u32 rkey;
> > > > +		} fast_reg;
> > > > +		struct {
> > > > +			__u32 remote_qpn;
> > > > +			__u32 remote_qkey;
> > > > +			struct pvrdma_av av;
> > > > +		} ud;
> > > > +	} wr;
> > > > +};
> > > >
> > > > No, I have half-baked patch series which refactors this structure in kernel.
> > > > There is no need to put this structure in UAPI.
> > > >
> >
> > This is specific to our device.. We do need to enqueue the WQE in this format
> > for the device to recognize it. This is the same format that the user-level
> > library will put the WQE in. As I said above, we can move this to the main
> > pvrdma driver directory if you prefer.
> 
> This is different implementations between kernel and user space.
> We don't want to bring user space limitations to kernel.
> Take a look here:
> http://lxr.free-electrons.com/source/include/rdma/ib_verbs.h#L1192
>

We anyway convert the WR structs defined there to our own device-specific
format. Similarly, in the user-level library we would convert from the
user-space WR structure to a device-specific structure. The struct above
defines the device-specific format.

There might be some overlap in these structures with userspace and kernel,
since some of the same opcodes would be supported between the two.
As long as OFED hides those limitations shouldnt it be okay to have similar
structures between the two?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
