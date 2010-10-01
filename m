From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support Nokia Slim Modems
Date: Fri, 1 Oct 2010 11:42:44 +0300
Message-ID: <201010011142.45767.remi@remlab.net>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com> <201009292121.18274.remi.denis-courmont@nokia.com> <20100930071952.GA21859@bnru01.bnr.st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"STEricsson_nomadik_linux" <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:54250 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295Ab0JAIm5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 04:42:57 -0400
In-Reply-To: <20100930071952.GA21859@bnru01.bnr.st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Hello,

On Thursday 30 September 2010, Kumar SANGHVI wrote:
> Hi R=E9mi Denis-Courmont,
>=20
> On Wed, Sep 29, 2010 at 20:21:17 +0200, R=E9mi Denis-Courmont wrote:
> > It seems to me that you really want to implement the connect() sock=
et
> > call, so that one of the two endpoints will stand up for the missin=
g
> > controller.
>=20
> Yes, implementing connect() socket call would be nice.
>=20
> > That's
> > still much cleaner than CREATE and DESTROY ioctl()'s.
>=20
> I have not introduced any new ioctl()'s as part of Pipe controller
> implementation.

Sure. What you did is basically worse than ioctl()'s. You've implemente=
d them=20
as socket options. Socket options are meant to configure parameters wit=
h=20
setsockopt and read paramters with getsockopt. They are not meant for '=
doing'=20
things - that's what ioctl()'s are for.

> The PIPE_CREATE/PIPE_DESTROY/PIPE_ENABLE/PIPE_DISABLE are all provide=
d
> as socket options.
> So, user-space can call setsockopt for creating/enabling or
> disabling/destroying pipe.

That makes absolutely no sense if you consider how setsockopt and getso=
ckopt=20
are supposed to work.

> Regarding implementing connect() socket call, few queries:
> 1. It should carry out all the same steps which I am currently doing =
as
> part of PIPE_CREATE socket option, right?
> 2. Currently, as part of Pipe controller implementation, user-space
>    follows below sequence:-
> 	socket()
> 	bind()
> 	listen()
> 	setsockopt(PIPE_CREATE)
> 	accept()'
>=20
>    In the phonet stack pipe controller logic, we wait for PEP_CONNECT=
_RESP
>    from host-pep (GPRS socket or video telephony socket is a host-pep=
=2E
>    pep_reply sends out the PEP_CONNECT_RESP) and remote-pep (modem),
>    negotiate the best flow-control to be used, and then send
>    PIPE_CREATED_IND, with selected flow-control to both pipe end-poin=
ts.

connect() should replace listen(), PIPE_CREATE and accept().

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
