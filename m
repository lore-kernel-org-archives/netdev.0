From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Tue, 15 Apr 2008 20:01:58 +0200
Message-ID: <200804152001.58528.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <20080415151403.GA20735@gerrit.erg.abdn.ac.uk> <20080415152113.GB20735@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2345 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbYDOSCO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 14:02:14 -0400
In-Reply-To: <20080415152113.GB20735@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Tuesday 15 of April 2008, Gerrit Renker napisa=B3:
> | | What happens if application is compiled with dccp_packet_info
> | | containing only one field (priority) and kernel containing two fi=
elds
> | | (for example priority and later added expiry time)? Wouldn't that
> | | implementation make extensions to dccp_packet_info impossible?
> |
> | Had not looked at it from this point of view. So you are suggesting
> |
> | 	if (msg->msg_control !=3D NULL && msg->msg_controllen >=3D sizeof(=
*dcp))
> | 		dcp =3D (struct dccp_packet_info *)msg->msg_control;
> |
> | instead? Agreed, point #1 to change in the patch.
>
> No, the above is nonsense. If the application uses an earlier version=
 of
> the API, then it needs to be recompiled, there is no way it could pre=
tend
> to have an adequate size.
>
That would effectively stop development of any policy. And it's not abo=
ut=20
pretending the structure has different size, it's just about using only=
 the=20
data that is provided by the application (even though it may be incompl=
ete).

> So my take is that still the '=3D=3D' is correct. But maybe this is a=
 known
> problem?
>
I can't see a problem with copying smaller struct to bigger one. It wou=
ld work=20
like that:
1. set default values for in-kernel structure,
2. copy min(msg_control, sizeof(struct dccp_packet_info)) bytes from us=
erspace=20
structure to the kernel one.

In that sense the code above is in fact wrong but the idea alone should=
 be ok.
--=20
Regards,
Tomasz Grobelny
