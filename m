From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v2 1/3] sctp: Export struct sctp_info to userspace
Date: Thu, 4 Aug 2016 11:27:20 +0200
Message-ID: <20160804092720.GC8988@orbyte.nwl.cc>
References: <1470259393-22861-1-git-send-email-phil@nwl.cc>
 <1470259393-22861-2-git-send-email-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6D5F509220@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54574 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757194AbcHDJ12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 05:27:28 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F509220@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 04, 2016 at 09:13:03AM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 03 August 2016 22:23
> > This is required to correctly interpret INET_DIAG_INFO messages exported
> > by sctp_diag module.
> ...
> > diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> > index de1f64318fc4e..fcb4c36461732 100644
> > --- a/include/linux/sctp.h
> > +++ b/include/linux/sctp.h
> > @@ -705,70 +705,6 @@ typedef struct sctp_auth_chunk {
> >  	sctp_authhdr_t auth_hdr;
> >  } __packed sctp_auth_chunk_t;
> > 
> > -struct sctp_info {
> > -	__u32	sctpi_tag;
> ...
> > -	__u32	__reserved3;
> > -};
> > -
> >  struct sctp_infox {
> >  	struct sctp_info *sctpinfo;
> >  	struct sctp_association *asoc;
> > diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> > index d304f4c9792c4..a406adcc0793e 100644
> > --- a/include/uapi/linux/sctp.h
> > +++ b/include/uapi/linux/sctp.h
> > @@ -944,4 +944,68 @@ struct sctp_default_prinfo {
> >  	__u16 pr_policy;
> >  };
> > 
> > +struct sctp_info {
> > +	__u32	sctpi_tag;
> 
> Should these be uint32_t (etc) for userspace?

Grepping through include/uapi in my clone of net-next, I see 271 results
for uint32_t but 4595 ones for __u32. So while not necessarily correct,
it seems to be the far more popular choice. Do you see any benefit in
using the uint*_t typedefs instead?

> > +	__u32	sctpi_state;
> ...
> > +	__u16	__reserved1;
> 
> Is it worth adding some extra pad here in case anything extra needs
> to be added to this set of data?
> 
> ...
> > +	__u32	__reserved3;
> 
> Think I'd definitely add a few words of pad here.
> Or at least make absolutely sure the interface passes the buffer length and
> allows for kernels that report different length buffers.

I merely copy and pasted the struct from include/linux/sctp.h without
thinking about it's layout. Xin, what are your thoughts about this?

Thanks, Phil
