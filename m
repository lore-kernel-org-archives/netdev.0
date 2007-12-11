From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH v2] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 12:15:00 -0500
Message-ID: <200712111215.00720.paul.moore@hp.com>
References: <20071211163019.15059.73746.stgit@flek.lan> <20071211.090611.59888503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:35319 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410AbXLKRPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 12:15:49 -0500
In-Reply-To: <20071211.090611.59888503.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 December 2007 12:06:11 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Tue, 11 Dec 2007 11:30:19 -0500
>
> Sorry for not pointing this out sooner:

No problem, better late than never ... despite reports to the contrary, 
breaking userspace doesn't excite me as much as it used to ;)

> >  * Convert 'sid' to 'secid'
> >    The 'sid' name is specific to SELinux, 'secid' is the common naming
> >    convention used by the kernel when refering to tokenized LSM labels
>
>  ...
>
> > diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> > index b58adc5..f75a337 100644
> > --- a/include/linux/xfrm.h
> > +++ b/include/linux/xfrm.h
> > @@ -31,7 +31,7 @@ struct xfrm_sec_ctx {
> >  	__u8	ctx_doi;
> >  	__u8	ctx_alg;
> >  	__u16	ctx_len;
> > -	__u32	ctx_sid;
> > +	__u32	ctx_secid;
> >  	char	ctx_str[0];
> >  };
>
> This datastructure has been exported to userspace, so we really can't
> member names unless it was added only in 2.6.24 and I don't think it
> was.
>
> Correct me if I'm wrong.

Ungh, I didn't think the whole structure was exported to userspace as a single 
binary blob; I'd assumed it was passed back and forth as individual 
fields/attributes.  I guess the old adage about assuming applies here ...

Grrr, that "sid" really bothers me but I guess it's a wart we're going to have 
to live with.  Stoopid userspace :)

I still would like to see the rest of the changes make it into 2.6.25 (the SPI 
byte order thing is particularly troublesome) so if you don't mind a "v3" 
I'll respin this patch right now to remove the "sid -> secid" bits.

-- 
paul moore
linux security @ hp
