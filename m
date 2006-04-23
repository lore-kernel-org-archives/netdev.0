From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sun, 23 Apr 2006 02:05:32 +0200
Message-ID: <200604230205.33668.ioe-lkml@rameria.de>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <200604221529.59899.ioe-lkml@rameria.de> <20060422134956.GC6629@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay01.ispgateway.de ([80.67.18.13]:38577 "EHLO
	smtprelay01.ispgateway.de") by vger.kernel.org with ESMTP
	id S1750938AbWDWAH7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 20:07:59 -0400
To: =?iso-8859-1?q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20060422134956.GC6629@wohnheim.fh-wedel.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, 22. April 2006 15:49, J=F6rn Engel wrote:
> That was another main point, yes.  And the endpoints should be as
> little burden on the bottlenecks as possible.  One bottleneck is the
> receive interrupt, which shouldn't wait for cachelines from other cpu=
s
> too much.

Thats right. This will be made a non issue with early demuxing
on the NIC and MSI (or was it MSI-X?) which will select
the right CPU based on hardware channels.

In the meantime I would reduce the effects with only committing
on full buffer or on leaving the interrupt handler.=20

This would be ok, because here you have to wakeup the process
anyway on full buffer and if it slept because of empty buffer.=20

You loose only, if your application didn't sleep yet and you need to
leave the interrupt handler because there is no work anymore.
In this case the atomic_add would be significant.

All this is quite similiar to now we do page_vec stuff in mm/ already.


Regards

Ingo Oeser
