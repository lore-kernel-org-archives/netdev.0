From: Norbert Eicker <n.eicker@fz-juelich.de>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Mon, 12 Mar 2007 10:45:48 +0100
Message-ID: <200703121045.49211.n.eicker@fz-juelich.de>
References: <20070308231556.GE30703@austin.ibm.com>
	<200703100016.58469.n.eicker@fz-juelich.de>
	<Pine.LNX.4.62.0703120927570.15144@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zam837.fz-juelich.de ([134.94.100.69]:47313 "HELO
	zam837.fz-juelich.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S965442AbXCLJpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 05:45:51 -0400
In-Reply-To: <Pine.LNX.4.62.0703120927570.15144@pademelon.sonytel.be>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 12. March 2007 09:28, Geert Uytterhoeven wrote:
> On Sat, 10 Mar 2007, Norbert Eicker wrote:
> > On Friday, 9. March 2007 17:53, Jeff Garzik wrote:
> > > Linas Vepstas wrote:
> > > > Please apply. The rather long patch description is from the
> > > > submitter, Norbert Eicker, I don't know if that's alright, or
> > > > if I should ask to have it trimmed.
> > > >
> > > > Thanks,
> > > > --linas
> > > >
> > > > From: Norbert Eicker <n.eicker@fz-juelich.de>
> > > >
> > > >
> > > > Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
> > > > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > >
> > > are you sure it can't send out fragmented IP frames?  what's
> > > really going on here?
> >
> > Pretty sure that fragmented IP frames are not send out. Here's a
> > small test using ttcp and tcpdump reproducing the problem (I assume
> > a MTU of 1500):
>
> Hence if I understand that correctly, NFS over UDP doesn't work at
> all as NFS uses 8 KiB UDP packets by default?

NFS seems to work but considering what I saw in tcpdump it uses TCP 
instead of UDP. I have not yet found out why NFS seems to default to 
TCP on Cell (the man-pages claims that UDP is the default).

If I explicitely demand to use UDP it indeed does not work at all.

Again if I use tcpdump on both sides, I see that the NFS-server claims 
to send out IP fragments containing the UDP datagrams (larger than 
MTU). The NFS-client does not see any of these fragments.

Using the patched spidernet module makes NFS work like a charm.


Norbert
-- 
Fon ++49-(0)2461/61-1492
http://www.fz-juelich.de

