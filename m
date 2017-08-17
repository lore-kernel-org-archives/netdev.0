From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH net-next 2/3] vsock: fix vsock_dequeue/enqueue_accept race
Date: Thu, 17 Aug 2017 15:05:41 +0100
Message-ID: <20170817140541.GH5539@stefanha-x1.localdomain>
References: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4630505951537180551=="
Cc: Michal Kubecek <mkubecek@suse.cz>, "joe@perches.com" <joe@perches.com>,
 "olaf@aepfle.de" <olaf@aepfle.de>, Stephen Hemminger <sthemmin@microsoft.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>, Jorgen Hansen <jhansen@vmware.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Marcelo Cerri <marcelo.cerri@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 George Zhang <georgezhang@vmware.com>,
 Dan Carpenter <dan.carpenter@oracle.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


--===============4630505951537180551==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qVHblb/y9DPlgkHs"
Content-Disposition: inline


--qVHblb/y9DPlgkHs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 10:15:39PM +0000, Dexuan Cui wrote:
> With the current code, when vsock_dequeue_accept() is removing a sock
> from the list, nothing prevents vsock_enqueue_accept() from adding a new
> sock into the list concurrently. We should add a lock to protect the list.

The listener sock is locked, preventing concurrent modification.  I have
checked both the virtio and vmci transports.  Can you post an example
where the listener sock isn't locked?

Stefan

--qVHblb/y9DPlgkHs
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZlaK1AAoJEJykq7OBq3PI6gIH/jhIxXUNZC7Kl6ciq4VSGrSi
PpsiYAKmye3ayDB7IObQn8o3vHRZyWJbbb9Rp8sN4ysmtPohtCNo2FhBJHwpwwjC
BpVZDk4GnmBLDlkhvzRtII+wWu1+mAy5hFCdwHaxuJdiACJOXU85mr6yGeWZH12D
9Kab5kgxZ8njSt3ICU4yk+QSuW/CP09ZXiihSwaXTDsQcmkpnZS9UYIchpmL2+wi
LNiqis0y3qhQ2QONXPHjn3y5FzIiQMQwtPjdkzbTD6t2x0wpjanOvsIKFHlq4jMw
6FMBE3VTARU5ig9xBHHuCOMJKW6Lq2RbAvq4MAMIQO+IJWp3s8QSEnaKQMZEElw=
=0Fib
-----END PGP SIGNATURE-----

--qVHblb/y9DPlgkHs--

--===============4630505951537180551==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============4630505951537180551==--
