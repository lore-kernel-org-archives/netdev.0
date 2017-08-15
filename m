From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 16:23:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005604E@AcuExch.aculab.com>
References: <20170815130020.29509-1-leonro@mellanox.com>
        <20170815130020.29509-3-leonro@mellanox.com>
 <20170815091205.2c39ea91@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "Ariel Almog" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170815091205.2c39ea91@xeon-e3>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger
> Sent: 15 August 2017 17:12
> On Tue, 15 Aug 2017 16:00:15 +0300
> Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> 
> > +
> > +static const char *dev_caps_to_str(uint32_t idx)
> > +{
> > +	uint64_t cap = 1 << idx;
> > +
> > +	switch (cap) {
> > +	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
> > +	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
...
> > +	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
> > +	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
> > +	default: return "UNKNOWN";
> > +	}
> 
> Could this be a table in future versions?

Potentially you could define the constants using some pre-processor
'magic' that would create the table for you.
Something like (but not compiled):

#define RDMA_DEV_FLAGS(x) \
	x(RESIZE_MAX_WR, 0) \
	x(BAD_PKEY_CNTR, 1) \
(continue for all the bits)

#define RDMA_DEV_ENUM(name, bit_no) RDMA_DEV_##name = BIT(bit_no),
enum {RDMA_DEV_FLAGS(RDMA_DEV_ENUM)};
#undef RDMA_DEV_ENUM

#define RDMA_DEV_NAMES(name, bit_no) [bit_no] = #name,
static const char rdma_dev_names[] = {RDMA_DEV_FLAGS(RDMA_DEV_NAMES)};

	David

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
