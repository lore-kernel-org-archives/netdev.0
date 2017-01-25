From: Varun Prakash <varun@chelsio.com>
Subject: Re: [PATCH] cxgbit: use T6 specific macro to set force bit
Date: Wed, 25 Jan 2017 12:08:10 +0530
Message-ID: <20170125063809.GB1668@chelsio.com>
References: <1485257822-729-1-git-send-email-varun@chelsio.com>
 <1485292300.12563.41.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "bart.vanassche@sandisk.com" <bart.vanassche@sandisk.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Indranil Choudhury <indranil@chelsio.com>
To: Joe Perches <joe@perches.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1485292300.12563.41.camel@perches.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2017 at 02:41:40AM +0530, Joe Perches wrote:
> On Tue, 2017-01-24 at 17:07 +0530, Varun Prakash wrote:
> > For T6 adapters use T6 specific macro to set
> > force bit.
> []
> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
> []
> > @@ -1349,6 +1349,10 @@ struct cpl_tx_data {
> >  #define TX_FORCE_S	13
> >  #define TX_FORCE_V(x)	((x) << TX_FORCE_S)
> >  
> > +#define T6_TX_FORCE_S		20
> > +#define T6_TX_FORCE_V(x)	((x) << T6_TX_FORCE_S)
> > +#define T6_TX_FORCE_F		T6_TX_FORCE_V(1U)
> > +
> >  enum {
> >  	ULP_TX_MEM_READ = 2,
> >  	ULP_TX_MEM_WRITE = 3,
> > diff --git a/drivers/target/iscsi/cxgbit/cxgbit_target.c b/drivers/target/iscsi/cxgbit/cxgbit_target.c
> []
> > @@ -162,12 +162,14 @@ cxgbit_tx_data_wr(struct cxgbit_sock *csk, struct sk_buff *skb, u32 dlen,
> >  		  u32 len, u32 credits, u32 compl)
> >  {
> >  	struct fw_ofld_tx_data_wr *req;
> > +	const struct cxgb4_lld_info *lldi = &csk->com.cdev->lldi;
> >  	u32 submode = cxgbit_skcb_submode(skb);
> >  	u32 wr_ulp_mode = 0;
> >  	u32 hdr_size = sizeof(*req);
> >  	u32 opcode = FW_OFLD_TX_DATA_WR;
> >  	u32 immlen = 0;
> > -	u32 force = TX_FORCE_V(!submode);
> > +	u32 force = is_t5(lldi->adapter_type) ? TX_FORCE_V(!submode) :
> > +		    T6_TX_FORCE_F;
> 
> Perhaps it'd be better to add a is_t6() mechanism so this
> is written in the positive rather than the negative.
>

At present cxgbit driver supports only T5 and T6 adapters so
if a adapter is not T5 then it is T6.
