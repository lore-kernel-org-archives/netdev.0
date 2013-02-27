From: "Roberts, Lee A." <lee.roberts@hp.com>
Subject: RE: [PATCH v2 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 20:26:39 +0000
Message-ID: <D64EC45690EF85409BA6C4730E0162244310F025@G4W3231.americas.hpqcorp.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
 <512E6905.2020808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "vyasevic@redhat.com" <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:1048 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab3B0U1n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:27:43 -0500
In-Reply-To: <512E6905.2020808@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Vlad Yasevich [mailto:vyasevic@redhat.com]
> Sent: Wednesday, February 27, 2013 1:14 PM
> To: Roberts, Lee A.
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH v2 0/4] sctp: fix association hangs due to reassembly/ordering logic
> 
> On 02/27/2013 01:54 PM, Lee A. Roberts wrote:
> > From: "Lee A. Roberts" <lee.roberts@hp.com>
> >
> > This series of patches resolves several SCTP association hangs observed during
> > SCTP stress testing.  Observable symptoms include communications hangs with
> > data being held in the association reassembly and/or lobby (ordering) queues.
> > Close examination of reassembly/ordering queues may show either duplicated
> > or missing packets.
> 
> Hi Lee
> 
> What changed in this series?  I looked through and they don't look
> different from the prior version?
> 
> -vlad
> 

Vlad,

In patch #4, routine sctp_ulpq_renege(), the inserted call to sctp_ulpq_partial_delivery()
still used the 3.2.x calling sequence with three arguments.

The first version of patch #4 stated:

+		if (retval <= 0)
+			sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
+		else if (retval == 1)
+			sctp_ulpq_reasm_drain(ulpq);

The second version of patch #4 has corrected the call to sctp_ulpq_partial_delivery():

+		if (retval <= 0)
+			sctp_ulpq_partial_delivery(ulpq, gfp);
+		else if (retval == 1)
+			sctp_ulpq_reasm_drain(ulpq);

I have adjusted the patch comments for yet another version of the patch series.
I'm holding them at the moment to collect any further change requests.

                                        - Lee



> >
> > Lee A. Roberts (4):
> >    sctp: fix association hangs due to off-by-one errors in
> >      sctp_tsnmap_grow()
> >    sctp: fix association hangs due to reneging packets below the
> >      cumulative TSN ACK point
> >    sctp: fix association hangs due to errors when reneging events from
> >      the ordering queue
> >    sctp: fix association hangs due to partial delivery errors
> >
> >   net/sctp/tsnmap.c   |   13 ++++----
> >   net/sctp/ulpqueue.c |   87 +++++++++++++++++++++++++++++++++++++++++----------
> >   2 files changed, 78 insertions(+), 22 deletions(-)
> >
