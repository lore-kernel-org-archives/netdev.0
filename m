From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Thu, 22 May 2008 15:59:55 -0700
Message-ID: <1211497195.18326.79.camel@dell>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
 <1211418386-18203-4-git-send-email-mchan@broadcom.com>
 <20080522211559.GA29851@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, michaelc@cs.wisc.edu,
	anilgv@broadcom.com, netdev <netdev@vger.kernel.org>,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com
To: "Christoph Hellwig" <hch@infradead.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080522211559.GA29851@infradead.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-05-22 at 17:15 -0400, Christoph Hellwig wrote:
> > +struct bnx2i_async_msg {
> > +#if defined(__BIG_ENDIAN)
> > +	u8 op_code;
> > +	u8 reserved1;
> > +	u16 reserved0;
> > +#elif defined(__LITTLE_ENDIAN)
> > +	u16 reserved0;
> > +	u8 reserved1;
> > +	u8 op_code;
> > +#endif
> > +	u32 reserved2;
> > +	u32 exp_cmd_sn;
> > +	u32 max_cmd_sn;
> > +	u32 reserved3[2];
> 
> Please don't do the ifdef big endian mess.  Just read the whole
> 32bit word and do mask and shift operations to extract the actual value.
> 
> 

I agree with you that u32 is cleaner in some cases.  We can just change
it to u32 op_code and we just need a OP_CODE_MASK of 0xff.

We'll go through this .h file and remove some of this big endian stuff
and also the duplicate constants pointed out earlier.



