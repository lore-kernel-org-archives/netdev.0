From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 02 Nov 2006 00:39:53 -0800 (PST)
Message-ID: <20061102.003953.55508453.davem@davemloft.net>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
	<20061102.001643.30183952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16025
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752651AbWKBIjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 03:39:55 -0500
To: mroos@linux.ee
In-Reply-To: <20061102.001643.30183952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 02 Nov 2006 00:16:43 -0800 (PST)

> From: Meelis Roos <mroos@linux.ee>
> Date: Thu, 2 Nov 2006 09:29:16 +0200 (EET)
> 
> >    CC [M]  net/sctp/sm_make_chunk.o
> > net/sctp/sm_make_chunk.c: In function 'sctp_unpack_cookie':
> > net/sctp/sm_make_chunk.c:1358: warning: initialization discards qualifiers from pointer target type
> > 
> > The reason is that sctp_unpack_cookie() takes a const struct 
> > sctp_endpoint and modifies the digest in it (digest being embedded in 
> > the struct, not a pointer). So sctp_unpack_cookie really does not use 
> > the argument as const, mark it as such.
> > 
> > Signed-off-by: Meelis Roos <mroos@linux.ee>
> 
> Applied,

Actually, I'm backing this one out, it creates new warnings because
callers of this function pass in a "const" pointer.

net/sctp/sm_statefuns.c: In function $,1rx(Bsctp_sf_do_5_1D_ce$,1ry(B:
net/sctp/sm_statefuns.c:630: warning: passing argument 1 of $,1rx(Bsctp_unpack_cookie$,1ry(B discards qualifiers from pointer target type
net/sctp/sm_statefuns.c: In function $,1rx(Bsctp_sf_do_5_2_4_dupcook$,1ry(B:
net/sctp/sm_statefuns.c:1884: warning: passing argument 1 of $,1rx(Bsctp_unpack_cookie$,1ry(B discards qualifiers from pointer target type

Please test the complete build when doing warning fixes like
this in the future, thanks.
