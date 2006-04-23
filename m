From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sat, 22 Apr 2006 22:52:34 -0700 (PDT)
Message-ID: <20060422.225234.36558278.davem@davemloft.net>
References: <200604211852.47335.netdev@axxeo.de>
	<20060422114846.GA6629@wohnheim.fh-wedel.de>
	<200604221529.59899.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joern@wohnheim.fh-wedel.de, netdev@axxeo.de, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22747
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751316AbWDWFwg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2006 01:52:36 -0400
To: ioe-lkml@rameria.de
In-Reply-To: <200604221529.59899.ioe-lkml@rameria.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ingo Oeser <ioe-lkml@rameria.de>
Date: Sat, 22 Apr 2006 15:29:58 +0200

> On Saturday, 22. April 2006 13:48, J=F6rn Engel wrote:
> > Unless I completely misunderstand something, one of the main points=
 of
> > the netchannels if to have *zero* fields written to by both produce=
r
> > and consumer.=20
>=20
> Hmm, for me the main point was to keep the complete processing
> of a single packet within one CPU/Core where this is a non-issue.

Both are the important issues.

You move the bulk of the packet processing work to the end
cores of the system, yes.  But you do so with an enormously
SMP friendly queue data structure so that it does not matter
at all that the packet is received on one cpu, yet processed
in socket context on another.

If you elide either part of the implementation, you miss the
entire point of net channels.
