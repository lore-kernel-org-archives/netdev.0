From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Thu, 27 Feb 2014 13:31:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CCBB2@AcuExch.aculab.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com>
 <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com>
 <530F3784.5050304@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36703 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753359AbaB0NdC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 08:33:02 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14001-05 for <netdev@vger.kernel.org>;
 Thu, 27 Feb 2014 13:32:57 +0000 (GMT)
In-Reply-To: <530F3784.5050304@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Giuseppe CAVALLARO
=2E..
> > Also (provided the hardware supports it) the rx buffers (are these
> > the ones being sized?) need to be aligned on a 4n+2 boundary in
> > order to avoid a realignment copy later on.
>=20
> This is true and indeed I had added the STMMAC_ALIGN to align all.
> In the past to get the right alignment for SH4.
>=20
> > So I'm not sure that some of these sizes are right and/or optimal.
>=20
> What do you suggest?
>=20
> Maybe, I can use a default for sure < 4KiB suitable to be used for VL=
AN
> frames (it will be aligned later).

Dunno... It rather depends on what the length is actually used for!
What you don=92t want to be doing is adding 2 (for the 4n+2) and then
mallocing a 4096+2 byte buffer somewhere.

If the hardware does receive desegmentation, then you need to handle
the 64k+ receives somewhere.
If it doesn't then it doesn't matter if the hardware rx buffer size is
slightly too large (eg for VLAN or encapsulation full sized frames in P=
PoE).
1536 bytes for the memory buffer avoids cache line sharing (read to
offset 2).

The last ethernet driver I wrote from scratch (maybe 20 years ago) set
the rx-ring to point to an array of 512 byte buffers (last was shorter
to avoid an extra page) and did an aligned copy into the message buffer=
=2E
Only frames that crossed the ring end needed two copies.
ISTR making the copy be cache line aligned so that a special cache line
copy function could be used (I don't know if it ever was).
=46or that system the cost of the aligned data copies was less that the
complexity and cost of setting up the iommu.

	David
