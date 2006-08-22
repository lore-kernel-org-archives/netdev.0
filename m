From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Tue, 22 Aug 2006 15:51:07 +0200
Message-ID: <200608221551.08406.ossthema@de.ibm.com>
References: <200608221453.49667.ossthema@de.ibm.com> <200608221601.24882.arnd.bergmann@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:36296 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP id S932267AbWHVObQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 10:31:16 -0400
To: Arnd Bergmann <arnd.bergmann@de.ibm.com>
In-Reply-To: <200608221601.24882.arnd.bergmann@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 22 August 2006 16:01, Arnd Bergmann wrote:
> > +=A0=A0=A0=A0=A0=A0=A0u64 rpage =3D 0;
> > +=A0=A0=A0=A0=A0=A0=A0int ret;
> > +=A0=A0=A0=A0=A0=A0=A0int cnt =3D 0;
> > +=A0=A0=A0=A0=A0=A0=A0void *vpage =3D NULL;
> > +
> > +=A0=A0=A0=A0=A0=A0=A0ret =3D hw_queue_ctor(hw_queue, nr_pages, EHE=
A_PAGESIZE, wqe_size);
> > +=A0=A0=A0=A0=A0=A0=A0if (ret)
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return ret;
> > +
> > +=A0=A0=A0=A0=A0=A0=A0for (cnt =3D 0; cnt < nr_pages; cnt++) {
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0vpage =3D hw_qpageit_=
get_inc(hw_queue);
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (!vpage) {
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0ehea_error("hw_qpageit_get_inc failed");
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0goto qp_alloc_register_exit0;
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rpage =3D virt_to_abs=
(vpage);
>=20
> As someone mentioned before, the initialization to 0 or NULL
> is pointless here, as the variables are always assigned before
> they are used. There are a number of other places in your
> code that do similar things, you should probably go through
> these and remove the initializers.
>=20
> If you indeed need something to be initialized, it is good practice
> to do the initialization as late as possible, e.g.
>=20
> 	int foo;
> 	...
> 	foo =3D 0;
> 	do_foo(foo);
>=20
> to make it clear that you have a reason to initialize it.
>=20
> 	Arnd <><
>=20

Agreed. We started to remove some but apparrently not all.
We'll go through the code and remove them where possible.

