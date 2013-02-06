From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] ip_gre: When TOS is inherited, use configured TOS value
 for non-IP packets
Date: Wed, 6 Feb 2013 16:23:48 -0500
Message-ID: <5112C9E4.6010708@ll.mit.edu>
References: <1359327899-8153-1-git-send-email-david.ward@ll.mit.edu>
 <20130129.140631.1784920486633961681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms000501080805020706070206"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"timo.teras@iki.fi" <timo.teras@iki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:46595 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756368Ab3BFVmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 16:42:24 -0500
In-Reply-To: <20130129.140631.1784920486633961681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms000501080805020706070206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On 01/29/2013 02:06 PM, David Miller wrote:
>
> From: David Ward <david.ward@ll.mit.edu>
> Date: Sun, 27 Jan 2013 18:04:58 -0500
>
> > A GRE tunnel can be configured so that outgoing tunnel packets inheri=
t
> > the value of the TOS field from the inner IP header. In doing so, whe=
n
> > a non-IP packet is transmitted through the tunnel, the TOS field will=

> > always be set to 0.
> >
> > Instead, the user should be able to configure a different TOS value a=
s
> > the fallback to use for non-IP packets. This is helpful when the non-=
IP
> > packets are all control packets and should be handled by routers outs=
ide
> > the tunnel as having Internet Control precedence. One example of this=
 is
> > the NHRP packets that control a DMVPN-compatible mGRE tunnel; they ar=
e
> > encapsulated directly by GRE and do not contain an inner IP header.
> >
> > Under the existing behavior, the IFLA_GRE_TOS parameter must be set t=
o
> > '1' for the TOS value to be inherited. Now, only the least significan=
t
> > bit of this parameter must be set to '1', and when a non-IP packet is=

> > sent through the tunnel, the upper 6 bits of this same parameter will=
 be
> > copied into the TOS field. (The ECN bits get masked off as before.)
> >
> > This behavior is backwards-compatible with existing configurations an=
d
> > iproute2 versions.
> >
> > Signed-off-by: David Ward <david.ward@ll.mit.edu>
>
> Seems reasonable, applied.  Thanks.
>
> I worry though about the case where tiph comes from skb->data rather
> than the tunnel parameter block, can you describe why this new behavior=

> is OK in that situation too.
>

Sorry for the late reply, I have not been well for the past few days.

The case you mentioned will occur when dev->header_ops has been set (to=20
ipgre_header_ops).  In that case, ipgre_header() is called before=20
ipgre_tunnel_xmit().  It pushes the outer IP header onto the SKB ahead=20
of time, copying the contents from the IP header in the tunnel parameter =

block.

So even in this case, the TOS value that we check is taken from the=20
tunnel parameter block, not the inner IP header.

David



--------------ms000501080805020706070206
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
--------------ms000501080805020706070206--
