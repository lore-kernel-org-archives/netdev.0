From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 02/16] IB/pvrdma: Add user-level shared functions
Date: Mon, 26 Sep 2016 09:13:38 +0300
Message-ID: <20160926061338.GH4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <b52db7f59d69089f7b1d53311574143c4da8252a.1474759181.git.aditr@vmware.com>
 <20160925072624.GV4088@leon.nu>
 <9c9f3668-ff2b-f421-2270-3193c0f62cc9@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="QFO1zB2dwAkGraMW"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50646 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932244AbcIZGNr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 02:13:47 -0400
Content-Disposition: inline
In-Reply-To: <9c9f3668-ff2b-f421-2270-3193c0f62cc9@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--QFO1zB2dwAkGraMW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 25, 2016 at 09:22:11PM -0700, Adit Ranadive wrote:
> On Sun, Sep 25 2016 at 10:26:24AM +0300, Leon Romanovsky wrote:
> > > On Sat, Sep 24, 2016 at 04:21:26PM -0700, Adit Ranadive wrote:
> > > We share some common structures with the user-level driver. This patch adds
> > > those structures and shared functions to traverse the QP/CQ rings.
>
> <...>
>
> > > +
> > > +#include <linux/types.h>
> > > +
> > > +#define PVRDMA_UVERBS_ABI_VERSION	3
> > > +#define PVRDMA_BOARD_ID			1
> > > +#define PVRDMA_REV_ID			1
> > >
> > > Please don't add defines which you are not using in the library and the
> > > two above are not in use.
> > >
>
> I'll move these to the pvrdma.h file.
>
> <...>
>
> > > diff --git a/include/uapi/rdma/pvrdma-uapi.h b/include/uapi/rdma/pvrdma-uapi.h
> > > new file mode 100644
> > > index 0000000..430d8a5
>
> <...>
>
> > > +
> > > +#ifndef __PVRDMA_UAPI_H__
> > > +#define __PVRDMA_UAPI_H__
> > > +
> > > +#include <linux/types.h>
> > > +
> > > +#define PVRDMA_VERSION 17
> > >
> > > What do you plan to do with this VERSION?
> > > How is it related to ABI?
> > >
>
> Not related. This is only for the driver to know which APIs to support.
> For example, an older driver would still be able to work with a newer
> device. I can move this to pvrdma.h as well.
>
> To be honest, I thought I can move this file into the uapi folder since
> the structures here are shared with the user-level library. Based on
> your comments in this thread and the other ones, I think it makes sense
> to move this file back to the pvrdma driver folder and rename it
> (pvrdma_wqe.h?) to avoid confusion. There might still be some duplicate
> code (especially the UAR offsets and WQE structs) here and in our
> user-level library.
>
> Let me know if that makes sense.
>
> > > +
> > > +#define PVRDMA_UAR_HANDLE_MASK	0x00FFFFFF	/* Bottom 24 bits. */
> > > +#define PVRDMA_UAR_QP_OFFSET	0		/* Offset of QP doorbell. */
> > > +#define PVRDMA_UAR_QP_SEND	BIT(30)		/* Send bit. */
> > > +#define PVRDMA_UAR_QP_RECV	BIT(31)		/* Recv bit. */
> > > +#define PVRDMA_UAR_CQ_OFFSET	4		/* Offset of CQ doorbell. */
> > > +#define PVRDMA_UAR_CQ_ARM_SOL	BIT(29)		/* Arm solicited bit. */
> > > +#define PVRDMA_UAR_CQ_ARM	BIT(30)		/* Arm bit. */
> > > +#define PVRDMA_UAR_CQ_POLL	BIT(31)		/* Poll bit. */
> > > +#define PVRDMA_INVALID_IDX	-1		/* Invalid index. */
> > >
> > > +
> > > +/* PVRDMA atomic compare and swap */
> > > +struct pvrdma_exp_cmp_swap {
> > >
> > > _EXP_ looks very similar to MLNX_OFED naming convention.
> > >
>
> Yes, the operation was based on that. Any concerns?
> I can rename this and the one below.

Yes, please.
The common practice in IB subsystem is to use _ex_ notation for such
extended structures.

>
> > > +	__u64 swap_val;
> > > +	__u64 compare_val;
> > > +	__u64 swap_mask;
> > > +	__u64 compare_mask;
> > > +};
> > > +
> > > +/* PVRDMA atomic fetch and add */
> > > +struct pvrdma_exp_fetch_add {
> > >
> > > The same as above.
> > >
> > > +	__u64 add_val;
> > > +	__u64 field_boundary;
> > > +};
> > > +
> > > +/* PVRDMA address vector. */
> > > +struct pvrdma_av {
> > > +	__u32 port_pd;
> > > +	__u32 sl_tclass_flowlabel;
> > > +	__u8 dgid[16];
> > > +	__u8 src_path_bits;
> > > +	__u8 gid_index;
> > > +	__u8 stat_rate;
> > > +	__u8 hop_limit;
> > > +	__u8 dmac[6];
> > > +	__u8 reserved[6];
> > > +};
> > > +
> > > +/* PVRDMA scatter/gather entry */
> > > +struct pvrdma_sge {
> > > +	__u64   addr;
> > > +	__u32   length;
> > > +	__u32   lkey;
> > > +};
> > > +
> > > +/* PVRDMA receive queue work request */
> > > +struct pvrdma_rq_wqe_hdr {
> > > +	__u64 wr_id;		/* wr id */
> > > +	__u32 num_sge;		/* size of s/g array */
> > > +	__u32 total_len;	/* reserved */
> > > +};
> > > +/* Use pvrdma_sge (ib_sge) for receive queue s/g array elements. */
> > > +
> > > +/* PVRDMA send queue work request */
> > > +struct pvrdma_sq_wqe_hdr {
> > > +	__u64 wr_id;		/* wr id */
> > > +	__u32 num_sge;		/* size of s/g array */
> > > +	__u32 total_len;	/* reserved */
> > > +	__u32 opcode;		/* operation type */
> > > +	__u32 send_flags;	/* wr flags */
> > > +	union {
> > > +		__u32 imm_data;
> > > +		__u32 invalidate_rkey;
> > > +	} ex;
> > > +	__u32 reserved;
> > > +	union {
> > > +		struct {
> > > +			__u64 remote_addr;
> > > +			__u32 rkey;
> > > +			__u8 reserved[4];
> > > +		} rdma;
> > > +		struct {
> > > +			__u64 remote_addr;
> > > +			__u64 compare_add;
> > > +			__u64 swap;
> > > +			__u32 rkey;
> > > +			__u32 reserved;
> > > +		} atomic;
> > > +		struct {
> > > +			__u64 remote_addr;
> > > +			__u32 log_arg_sz;
> > > +			__u32 rkey;
> > > +			union {
> > > +				struct pvrdma_exp_cmp_swap  cmp_swap;
> > > +				struct pvrdma_exp_fetch_add fetch_add;
> > > +			} wr_data;
> > > +		} masked_atomics;
> > > +		struct {
> > > +			__u64 iova_start;
> > > +			__u64 pl_pdir_dma;
> > > +			__u32 page_shift;
> > > +			__u32 page_list_len;
> > > +			__u32 length;
> > > +			__u32 access_flags;
> > > +			__u32 rkey;
> > > +		} fast_reg;
> > > +		struct {
> > > +			__u32 remote_qpn;
> > > +			__u32 remote_qkey;
> > > +			struct pvrdma_av av;
> > > +		} ud;
> > > +	} wr;
> > > +};
> > >
> > > No, I have half-baked patch series which refactors this structure in kernel.
> > > There is no need to put this structure in UAPI.
> > >
>
> This is specific to our device.. We do need to enqueue the WQE in this format
> for the device to recognize it. This is the same format that the user-level
> library will put the WQE in. As I said above, we can move this to the main
> pvrdma driver directory if you prefer.

This is different implementations between kernel and user space.
We don't want to bring user space limitations to kernel.
Take a look here:
http://lxr.free-electrons.com/source/include/rdma/ib_verbs.h#L1192

>
> > > +/* Use pvrdma_sge (ib_sge) for send queue s/g array elements. */
> > > +
> > > +/* Completion queue element. */
> > > +struct pvrdma_cqe {
> > > +	__u64 wr_id;
> > > +	__u64 qp;
> > > +	__u32 opcode;
> > > +	__u32 status;
> > > +	__u32 byte_len;
> > > +	__u32 imm_data;
> > > +	__u32 src_qp;
> > > +	__u32 wc_flags;
> > > +	__u32 vendor_err;
> > > +	__u16 pkey_index;
> > > +	__u16 slid;
> > > +	__u8 sl;
> > > +	__u8 dlid_path_bits;
> > > +	__u8 port_num;
> > > +	__u8 smac[6];
> > > +	__u8 reserved2[7]; /* Pad to next power of 2 (64). */
> > > +};
> > > +
> > > +struct pvrdma_ring {
> > > +	atomic_t prod_tail;	/* Producer tail. */
> > > +	atomic_t cons_head;	/* Consumer head. */
> > > +};
> > > +
> > > +struct pvrdma_ring_state {
> > > +	struct pvrdma_ring tx;	/* Tx ring. */
> > > +	struct pvrdma_ring rx;	/* Rx ring. */
> > > +};
> > > +
> > > +static inline int pvrdma_idx_valid(__u32 idx, __u32 max_elems)
> > > +{
> > > +	/* Generates fewer instructions than a less-than. */
> > > +	return (idx & ~((max_elems << 1) - 1)) == 0;
> > > +}
> > > +
> > > +static inline __s32 pvrdma_idx(atomic_t *var, __u32 max_elems)
> > > +{
> > > +	const unsigned int idx = atomic_read(var);
> > > +
> > > +	if (pvrdma_idx_valid(idx, max_elems))
> > > +		return idx & (max_elems - 1);
> > > +	return PVRDMA_INVALID_IDX;
> > > +}
> > > +
> > > +static inline void pvrdma_idx_ring_inc(atomic_t *var, __u32 max_elems)
> > > +{
> > > +	__u32 idx = atomic_read(var) + 1;	/* Increment. */
> > >
> > > It is definitely different atomic_read than you expect. From my grep
> > > searches on my machine, linux kernel doesn't export in standard headers
> > > the atomic_* functions and C has their implementation of that functions.
> > >
>
> This would probably change for the user-level library, so no need have this file
> in UAPI.
>
> > > +
> > > +	idx &= (max_elems << 1) - 1;		/* Modulo size, flip gen. */
> > > +	atomic_set(var, idx);
> > > +}
> > > +
> > > +static inline __s32 pvrdma_idx_ring_has_space(const struct pvrdma_ring *r,
> > > +					      __u32 max_elems, __u32 *out_tail)
> > > +{
> > > +	const __u32 tail = atomic_read(&r->prod_tail);
> > > +	const __u32 head = atomic_read(&r->cons_head);
> > > +
> > > +	if (pvrdma_idx_valid(tail, max_elems) &&
> > > +	    pvrdma_idx_valid(head, max_elems)) {
> > > +		*out_tail = tail & (max_elems - 1);
> > > +		return tail != (head ^ max_elems);
> > > +	}
> > > +	return PVRDMA_INVALID_IDX;
> > > +}
> > > +
> > > +static inline __s32 pvrdma_idx_ring_has_data(const struct pvrdma_ring *r,
> > > +					     __u32 max_elems, __u32 *out_head)
> > > +{
> > > +	const __u32 tail = atomic_read(&r->prod_tail);
> > > +	const __u32 head = atomic_read(&r->cons_head);
> > > +
> > > +	if (pvrdma_idx_valid(tail, max_elems) &&
> > > +	    pvrdma_idx_valid(head, max_elems)) {
> > > +		*out_head = head & (max_elems - 1);
> > > +		return tail != head;
> > > +	}
> > > +	return PVRDMA_INVALID_IDX;
> > > +}
> > > +
> > > +static inline bool pvrdma_idx_ring_is_valid_idx(const struct pvrdma_ring *r,
> > > +						__u32 max_elems, __u32 *idx)
> > > +{
> > > +	const __u32 tail = atomic_read(&r->prod_tail);
> > > +	const __u32 head = atomic_read(&r->cons_head);
> > > +
> > > +	if (pvrdma_idx_valid(tail, max_elems) &&
> > > +	    pvrdma_idx_valid(head, max_elems) &&
> > > +	    pvrdma_idx_valid(*idx, max_elems)) {
> > > +		if (tail > head && (*idx < tail && *idx >= head))
> > > +			return true;
> > > +		else if (head > tail && (*idx >= head || *idx < tail))
> > > +			return true;
> > > +	}
> > > +	return false;
> > > +}
> > > +
> > > +#endif /* __PVRDMA_UAPI_H__ */
> > >
> > > I suggest completely remove this file from UAPI headers folder.
> > >
>
> I can move this back to the pvrdma driver folder.

Yes, please.

--QFO1zB2dwAkGraMW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX6LySAAoJEORje4g2clin6eAQALXWVWkwDPHBGDI/lojjl5Yd
u0YIGb9KwShluM+dXVBT6FeCfZCn+oBgYPgGKKWVpF52YnGtb6CdLZ1tWlI1LDPg
TkXPHPJx1oSOzom3RQhGO9aoFl1V8672hvk2n9xvdnVCKQndr3jxx+l6X2jIBRJR
RMQJD09OAwugX0dsN9cv4sZW2jfpt6leCyJemQIKyGafpA2V+clLgJVrkDpHuo4q
ISWNHBbIHeMuTU12H/j+wwmKSkQnQUhKwfTOrVwiyS9FWdFU9W3fKBHfuxt+YwQn
iAZT5Xqyf0EsAEeq+xC21cbdhcposJ7EwmgwSXCGXvlXU1IWf2pmRrntM1A4KvXH
sG6OJD3IwQea/pouTqFJIRl7m0QR6LKlTSgl3X1vxc1WIYyEBfQ+wDJIJMoVKB7m
dNj0CY62R0ZK+9gyTH0CbzrGksBPHVjzNvg/2JKRx0uP56/NwUwXNAKd++qtpAs5
cCiiIB07p6xRvXlOOTZCedz+OJEYoZ4VDjOwR0M3dYspddU9hJVwH3uK1culJJah
ZHFn+Bi1lRkkknk1yuWd38FV9021bBpGOQk8/4EFtt5/Jx5z62lFcLDpl0AyRfws
zYtWV/X0Gyqtrbzo3bub8yBUe95Kbz0Qlj0Wv3hZyFVFnOZ8XoIFNdbh82fT3C6W
76WvG/mC0EDWm0rQ8EWx
=lYv5
-----END PGP SIGNATURE-----

--QFO1zB2dwAkGraMW--
