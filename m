From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 17:00:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005613D@AcuExch.aculab.com>
References: <20170815130020.29509-1-leonro@mellanox.com>
 <20170815130020.29509-3-leonro@mellanox.com>
 <20170815091205.2c39ea91@xeon-e3>
 <063D6719AE5E284EB5DD2968C1650D6DD005604E@AcuExch.aculab.com>
 <20170815164720.GV24282@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Stephen Hemminger' <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "Ariel Almog" <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: 'Leon Romanovsky' <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:50293 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752262AbdHORBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 13:01:09 -0400
In-Reply-To: <20170815164720.GV24282@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky
> Sent: 15 August 2017 17:47
> On Tue, Aug 15, 2017 at 04:23:11PM +0000, David Laight wrote:
> > From: Stephen Hemminger
> > > Sent: 15 August 2017 17:12
> > > On Tue, 15 Aug 2017 16:00:15 +0300
> > > Leon Romanovsky <leonro@mellanox.com> wrote:
> > >
> > > > +
> > > > +static const char *dev_caps_to_str(uint32_t idx)
> > > > +{
> > > > +	uint64_t cap = 1 << idx;
> > > > +
> > > > +	switch (cap) {
> > > > +	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
> > > > +	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
> > ...
> > > > +	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
> > > > +	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
> > > > +	default: return "UNKNOWN";
> > > > +	}
> > >
> > > Could this be a table in future versions?
> >
> > Potentially you could define the constants using some pre-processor
> > 'magic' that would create the table for you.
> > Something like (but not compiled):
> >
> > #define RDMA_DEV_FLAGS(x) \
> > 	x(RESIZE_MAX_WR, 0) \
> > 	x(BAD_PKEY_CNTR, 1) \
> > (continue for all the bits)
> >
> > #define RDMA_DEV_ENUM(name, bit_no) RDMA_DEV_##name = BIT(bit_no),
> > enum {RDMA_DEV_FLAGS(RDMA_DEV_ENUM)};
> > #undef RDMA_DEV_ENUM
> >
> > #define RDMA_DEV_NAMES(name, bit_no) [bit_no] = #name,
> > static const char rdma_dev_names[] = {RDMA_DEV_FLAGS(RDMA_DEV_NAMES)};
I missed the #undef
> >
> 
> David,
> 
> How should I handle "uknown" fields without names?

The function that accesses rdma_dev_names[] checks ARRAY_SIZE()
and for a NULL pointer.

WRT the other comment, the spare pointers consume far less space than
the code for your switch statement.

	David
