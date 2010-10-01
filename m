From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support
 Nokia Slim Modems
Date: Fri, 1 Oct 2010 14:25:55 +0530
Message-ID: <20101001085553.GA27109@bnru01.bnr.st.com>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
 <201009292121.18274.remi.denis-courmont@nokia.com>
 <20100930071952.GA21859@bnru01.bnr.st.com>
 <201010011142.45767.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	STEricsson_nomadik_linux <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:44756 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755301Ab0JAI4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 04:56:10 -0400
Content-Disposition: inline
In-Reply-To: <201010011142.45767.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 01, 2010 at 10:42:44 +0200, R=E9mi Denis-Courmont wrote:
 >=20
> > I have not introduced any new ioctl()'s as part of Pipe controller
> > implementation.
>=20
> Sure. What you did is basically worse than ioctl()'s. You've implemen=
ted them=20
> as socket options. Socket options are meant to configure parameters w=
ith=20
> setsockopt and read paramters with getsockopt. They are not meant for=
 'doing'=20
> things - that's what ioctl()'s are for.

Isn't the existing phonet stack 'doing' something as part of
PNPIPE_ENCAP rather than simply configuring some socket option or flag =
?
=20
> > Regarding implementing connect() socket call, few queries:
> > 1. It should carry out all the same steps which I am currently doin=
g as
> > part of PIPE_CREATE socket option, right?
> > 2. Currently, as part of Pipe controller implementation, user-space
> >    follows below sequence:-
> > 	socket()
> > 	bind()
> > 	listen()
> > 	setsockopt(PIPE_CREATE)
> > 	accept()'
> >=20
> >    In the phonet stack pipe controller logic, we wait for PEP_CONNE=
CT_RESP
> >    from host-pep (GPRS socket or video telephony socket is a host-p=
ep.
> >    pep_reply sends out the PEP_CONNECT_RESP) and remote-pep (modem)=
,
> >    negotiate the best flow-control to be used, and then send
> >    PIPE_CREATED_IND, with selected flow-control to both pipe end-po=
ints.
>=20
> connect() should replace listen(), PIPE_CREATE and accept().

Thanks. I will implement connect and upload the patch.

-Kumar.
