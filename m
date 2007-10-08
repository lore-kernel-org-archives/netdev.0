From: =?iso-8859-1?Q?Fran=E7ois-Fr=E9d=E9ric_Ozog?= <ff@ozog.com>
Subject: RE: [Bugme-new] [Bug 9132] New: fcntl GET_OWN reports 0 for sockets instead of PID
Date: Mon, 8 Oct 2007 20:16:10 +0200
Message-ID: <D0839CEFE3ADCD478181D300EFB732D23186@ozog-main.adainville.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <bugme-daemon@bugzilla.kernel.org>, <netdev@vger.kernel.org>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:52124 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755754AbXJHS1o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:27:44 -0400
Received: from smtp-msa-out01.orange.fr (mwinf2353 [10.232.4.161])
	by mwinf2340.orange.fr (SMTP Server) with ESMTP id 65B961C11E3A
	for <netdev@vger.kernel.org>; Mon,  8 Oct 2007 20:27:26 +0200 (CEST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You are correct, I have tested back to 2.6.18 and the bug is still here=
=2E So I don't know when the problem did NOT occur.

=46ran=E7ois-Fr=E9d=E9ric

-----Message d'origine-----
De=A0: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Envoy=E9=A0: lundi 8 octobre 2007 19:11
=C0=A0: Fran=E7ois-Fr=E9d=E9ric Ozog
Cc=A0: bugme-daemon@bugzilla.kernel.org; netdev@vger.kernel.org
Objet=A0: Re: [Bugme-new] [Bug 9132] New: fcntl GET_OWN reports 0 for s=
ockets instead of PID


(please respond via emailed reply-to-all, not vie the bugzilla web inte=
rface)

On Mon,  8 Oct 2007 09:18:02 -0700 (PDT) bugme-daemon@bugzilla.kernel.o=
rg wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=3D9132
>=20
>            Summary: fcntl GET_OWN reports 0 for sockets instead of PI=
D
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: ff@ozog.com
>=20
>=20
> Most recent kernel where this bug did not occur: 2.6.22
> Distribution: Kubuntu
> Hardware Environment: VMWare workstation 6
> Software Environment:=20
> Problem Description: calling fcntl with F_GETOWN on a socket gives al=
lways zero
> instead of the PID of the socket. The fcntl code is right but the dat=
a is zero
> in the struct file element. It sounds like pid is not set when the so=
cket is
> attached to the fd in sock_attach_fd() of net/socket.c.
>=20
> I would add something like this:
>=20
> file->f_owner.pid=3Dfind_get_pid(task->pid);
> file->f_owner.pid_type=3DPIDTYPE_PID;
>=20
> in sock_attach_fd() of net/socket.c
>=20
> Steps to reproduce:
>=20
> s=3Dsocket(...);
> pid=3Dfcntl(s, F_GETOWN);
>=20

You state that the problem is present in 2.6.22 and also did not occur =
in
2.6.22.  I assume it has always been like this.

