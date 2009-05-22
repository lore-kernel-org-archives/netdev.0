From: steve@chygwyn.com
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 22 May 2009 09:31:14 +0100
Message-ID: <20090522083114.GA15578@fogou.chygwyn.com>
References: <20090520230652.GB5956@ghostprotocols.net> <200905221022.48790.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:59171 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbZEVIiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 04:38:07 -0400
Content-Disposition: inline
In-Reply-To: <200905221022.48790.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, May 22, 2009 at 10:22:48AM +0300, R=E9mi Denis-Courmont wrote:
> On Thursday 21 May 2009 02:06:52 ext Arnaldo Carvalho de Melo wrote:
> > +       /*
> > +        * We may return less entries than requested (vlen) if the
> > +        * sock is non block and there aren't enough datagrams.
> > +        */
> > +       if (err =3D=3D 0 || (err =3D=3D -EAGAIN && (flags & MSG_DON=
TWAIT)))
> > +               return datagrams;
> >         return err;
> >  }
>=20
> Could there be a situation whereby we receive one or more datagrams, =
then get=20
> an error? How does userland get the datagrams then?
>
Normally you'd expect the call to return what it has read without an
error, and then the socket error would be picked up on the next call.
Need to check if sk->sk_error is being reset in the common code I
guess,

Steve.
