From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 net-next 3/4] sctp: add support for generating stream
 reconf add incoming/outgoing streams request chunk
Date: Mon, 23 Jan 2017 12:26:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026B8E0@AcuExch.aculab.com>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <0d8d8e5482205ead64a2cfd2d414e918ce5602dd.1484845510.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB026900F@AcuExch.aculab.com>
 <20170120163921.GU3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:58899 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdAWM03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 07:26:29 -0500
In-Reply-To: <20170120163921.GU3781@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner > Sent: 20 January 2017 16:39
> To: David Laight
> On Fri, Jan 20, 2017 at 02:50:01PM +0000, David Laight wrote:
> > From: Xin Long
> > > Sent: 19 January 2017 17:19
> > > This patch is to define Add Incoming/Outgoing Streams Request
> > > Parameter described in rfc6525 section 4.5 and 4.6. They can
> > > be in one same chunk trunk as rfc6525 section 3.1-7 describes,
> > > so make them in one function.
> > ...
> > > +struct sctp_strreset_addstrm {
> > > +	sctp_paramhdr_t param_hdr;
> > > +	__u32 request_seq;
> > > +	__u16 number_of_streams;
> > > +	__u16 reserved;
> > > +} __packed;
> > ...
> > > +		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_OUT_STREAMS;
> > > +		addstrm.param_hdr.length = htons(size);
> > > +		addstrm.number_of_streams = htons(out);
> > > +		addstrm.request_seq = htonl(asoc->strreset_outseq);
> > > +		addstrm.reserved = 0;
> > > +
> > > +		sctp_addto_chunk(retval, size, &addstrm);
> >
> > Since you allocate the sctp_strreset_addstrm structure on stack
> > there is no requirement for it to be packed.
> 
> It shouldn't matter that it's allocated on stack. Why should it?
> We need it to be packed as this is a header that will be sent out to
> another peer, so there can't be any padding on it.

That isn't what __packed means.
It means that the compiler must assume that the structure can be
misaligned in memory and must use byte memory accesses on systems
that fault misaligned memory accesses.

	David
