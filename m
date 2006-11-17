From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  09/13] Core WQE/CQE Types
Date: Thu, 16 Nov 2006 20:45:36 -0800
Message-ID: <adaveleof4f.fsf@cisco.com>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>
	<20061116035912.22635.21736.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1424607AbWKQEpj@vger.kernel.org>
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20061116035912.22635.21736.stgit@dell3.ogc.int> (Steve Wise's message of "Wed, 15 Nov 2006 21:59:12 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +struct t3_send_wr {
 > +	struct fw_riwrh wrh;	/* 0 */
 > +	union t3_wrid wrid;	/* 1 */
 > +
 > +	enum t3_rdma_opcode rdmaop:8;
 > +	u32 reserved:24;	/* 2 */

Does this do the right thing wrt endianness?  I'd be more comfortable
with something like

	u8 rdmaop;
        u8 reserved[3];

(although the __attribute__((packed)) on enum t3_rdma_opcode does make
it OK to use here, I guess)

 > +	u32 rem_stag;		/* 2 */
 > +	u32 plen;		/* 3 */
 > +	u32 num_sgle;
 > +	struct t3_sge sgl[T3_MAX_SGE];	/* 4+ */
 > +};
