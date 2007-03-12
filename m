From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Mon, 12 Mar 2007 11:44:46 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0703121130100.15998@pademelon.sonytel.be>
References: <20070308231556.GE30703@austin.ibm.com>  <200703100016.58469.n.eicker@fz-juelich.de>
  <Pine.LNX.4.62.0703120927570.15144@pademelon.sonytel.be>
 <200703121045.49211.n.eicker@fz-juelich.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux/PPC Development <linuxppc-dev@ozlabs.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Norbert Eicker <n.eicker@fz-juelich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:44510 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S965533AbXCLKos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 06:44:48 -0400
In-Reply-To: <200703121045.49211.n.eicker@fz-juelich.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Mar 2007, Norbert Eicker wrote:
> On Monday, 12. March 2007 09:28, Geert Uytterhoeven wrote:
> > On Sat, 10 Mar 2007, Norbert Eicker wrote:
> > > On Friday, 9. March 2007 17:53, Jeff Garzik wrote:
> > > > Linas Vepstas wrote:
> > > > > Please apply. The rather long patch description is from the
> > > > > submitter, Norbert Eicker, I don't know if that's alright, or
> > > > > if I should ask to have it trimmed.
> > > > >
> > > > > Thanks,
> > > > > --linas
> > > > >
> > > > > From: Norbert Eicker <n.eicker@fz-juelich.de>
> > > > >
> > > > >
> > > > > Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
> > > > > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > > >
> > > > are you sure it can't send out fragmented IP frames?  what's
> > > > really going on here?
> > >
> > > Pretty sure that fragmented IP frames are not send out. Here's a
> > > small test using ttcp and tcpdump reproducing the problem (I assume
> > > a MTU of 1500):
> >
> > Hence if I understand that correctly, NFS over UDP doesn't work at
> > all as NFS uses 8 KiB UDP packets by default?
> 
> NFS seems to work but considering what I saw in tcpdump it uses TCP 
> instead of UDP. I have not yet found out why NFS seems to default to 
> TCP on Cell (the man-pages claims that UDP is the default).

Hmm, I just checked and for me it defaults to UDP.

> If I explicitely demand to use UDP it indeed does not work at all.

And NFS over UDP works fine on my PS3 with the gelic Ethernet driver.
Ethereal (on the server side) did show fragmented packets.

However, I remember having NFS problems when using a different NFS server
before.  I just retried using that server, and got these error messages from
the gelic driver:

| error in received descriptor found, data_status=x70002300, data_error=x06100000
| ERROR DESTROY:6100000
| error in received descriptor found, data_status=x70002900, data_error=x06100000
| ERROR DESTROY:6100000

Ethereal (on the server side) did show fragmented packets with retransmissions.

So sometimes it works, sometimes it doesn't?

The differences between the 2 NFS servers are:
  - working one runs 2.6.11, non-working one runs 2.4.17
  - working one is on the same subnet as the PS3, non-working one isn't.
  - both work fine with e.g. my laptop as an NFS client
  - both have nfs-kernel-server 1:1.0.6-3.1
  - both have 3c905 Tornado Ethernet

For completeness, sometimes (1-2 times a week) I do see a similar gelic error
message when using the working NFS server, but it recovers fine and never is a
problem.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- Sony Network and Software Technology Center Europe (NSCE)
Geert.Uytterhoeven@sonycom.com ------- The Corporate Village, Da Vincilaan 7-D1
Voice +32-2-7008453 Fax +32-2-7008622 ---------------- B-1935 Zaventem, Belgium
