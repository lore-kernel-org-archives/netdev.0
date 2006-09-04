From: =?ISO-8859-1?Q?S=E9bastien_Dugu=E9?= <sebastien.dugue@bull.net>
Subject: Re: Kernel patches enabling better POSIX AIO (Was Re: [3/4]
	kevent: AIO, aio_sendfile)
Date: Mon, 04 Sep 2006 16:36:40 +0200
Message-ID: <1157380601.3895.53.camel@frecb000686>
References: <44C77C23.7000803@redhat.com> <44C796C3.9030404@us.ibm.com>
	 <1153982954.3887.9.camel@frecb000686> <44C8DB80.6030007@us.ibm.com>
	 <44C9029A.4090705@oracle.com>
	 <1154024943.29920.3.camel@dyn9047017100.beaverton.ibm.com>
	 <44C90987.1040200@redhat.com>
	 <1154034164.29920.22.camel@dyn9047017100.beaverton.ibm.com>
	 <1154091500.13577.14.camel@frecb000686> <44DCDE73.9030901@redhat.com>
	 <20060812182928.GA1989@in.ibm.com>  <44DE27AB.7040507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: suparna@in.ibm.com, Badari Pulavarty <pbadari@us.ibm.com>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-aio@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:18155 "EHLO
	ecfrec.frec.bull.fr") by vger.kernel.org with ESMTP
	id S1751400AbWIDOgs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 10:36:48 -0400
To: Ulrich Drepper <drepper@redhat.com>
In-Reply-To: <44DE27AB.7040507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-08-12 at 12:10 -0700, Ulrich Drepper wrote:
> Suparna Bhattacharya wrote:
> > I am wondering about that too. IIRC, the IO_NOTIFY_* constants are =
not
> > part of the ABI, but only internal to the kernel implementation. I =
think
> > Zach had suggested inferring THREAD_ID notification if the pid spec=
ified
> > is not zero. But, I don't see why ->sigev_notify couldn't used dire=
ctly
> > (just like the POSIX timers code does) thus doing away with the=20
> > new constants altogether. Sebestian/Laurent, do you recall?
>=20
> I suggest to model the implementation after the timer code which does
> exactly what we need.
>=20

  Will do.

>=20
> > I'm guessing they are being used for validation of permissions at t=
he time
> > of sending the signal, but maybe saving the task pointer in the ioc=
b instead
> > of the pid would suffice ?
>=20
> Why should any verification be necessary?  The requests are generated=
 in
> the same process which will receive the notification.  Even if the PO=
SIX
> process (aka, kernel process group) changes the IDs the notifications
> should be set.  The key is that notifications cannot be sent to anoth=
er
> POSIX process.
>=20
> Adding this as a feature just makes things so much more complicated.
>=20

  Agreed.

  S=E9bastien.


--=20
-----------------------------------------------------

  S=E9bastien Dugu=E9                BULL/FREC:B1-247
  phone: (+33) 476 29 77 70      Bullcom: 229-7770

  mailto:sebastien.dugue@bull.net

  Linux POSIX AIO: http://www.bullopensource.org/posix
                   http://sourceforge.net/projects/paiol

-----------------------------------------------------

