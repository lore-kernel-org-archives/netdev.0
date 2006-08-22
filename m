From: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Tue, 22 Aug 2006 16:01:24 +0200
Message-ID: <200608221601.24882.arnd.bergmann@de.ibm.com>
References: <200608221453.49667.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <200608221453.49667.ossthema@de.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 August 2006 14:53, Jan-Bernd Themann wrote:
> +=A0=A0=A0=A0=A0=A0=A0u64 rpage =3D 0;
> +=A0=A0=A0=A0=A0=A0=A0int ret;
> +=A0=A0=A0=A0=A0=A0=A0int cnt =3D 0;
> +=A0=A0=A0=A0=A0=A0=A0void *vpage =3D NULL;
> +
> +=A0=A0=A0=A0=A0=A0=A0ret =3D hw_queue_ctor(hw_queue, nr_pages, EHEA_PAGE=
SIZE, wqe_size);
> +=A0=A0=A0=A0=A0=A0=A0if (ret)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return ret;
> +
> +=A0=A0=A0=A0=A0=A0=A0for (cnt =3D 0; cnt < nr_pages; cnt++) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0vpage =3D hw_qpageit_get_in=
c(hw_queue);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (!vpage) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0ehe=
a_error("hw_qpageit_get_inc failed");
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0got=
o qp_alloc_register_exit0;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rpage =3D virt_to_abs(vpage=
);

As someone mentioned before, the initialization to 0 or NULL
is pointless here, as the variables are always assigned before
they are used. There are a number of other places in your
code that do similar things, you should probably go through
these and remove the initializers.

If you indeed need something to be initialized, it is good practice
to do the initialization as late as possible, e.g.

	int foo;
	...
	foo =3D 0;
	do_foo(foo);

to make it clear that you have a reason to initialize it.

	Arnd <><
