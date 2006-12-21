From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Thu, 21 Dec 2006 14:42:38 +0000
Message-ID: <200612211442.38493@strip-the-willow>
References: <200612141507.06888@strip-the-willow> <20061220.103112.85414445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55687 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422745AbWLUOml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 09:42:41 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061220.103112.85414445.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

many thanks for taking the matter seriously and investigating
it further.=20

|  I went over this patch and analysis a dozen times, because I
|  couldn't believe something like this has been broken for
|  so long :-)
It gave me some grief too, when I looked at DCCP sequence numbers %-)
RFC 1982 provides some definitions, but leaves the case a =3D (b + 2^31=
) % 2^32
open to the implementation (suggests `undefined').

I think the new definition is more conformant with RFC 1982 than the ol=
d one,
since the ambiguity is now removed with regard to a =3D (b + 2^31) % 32=
, and it
is not "unnecessarily burdensome to implement" (section 3.2 of RFC 1982=
).
 =20
|  Even BSD suffers of this issue, since the beginning. =A0See
|  SEQ_LT() in tcp_seq.h, and it seems that BSD's timestamp
|  sequence checking has the issue too (see TSTMP_LT() macro
|  in OpenBSD's tcp_input.c)
I didn't know about OpenBSD, but in Stevens vol 2 (sec. 24.7) it is
already defined in this way.=20

Best regards & merry Christmas
Gerrit
