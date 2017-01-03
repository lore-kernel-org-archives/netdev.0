From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] tun: rx batching
Date: Tue, 3 Jan 2017 13:33:03 +0000
Message-ID: <20170103133303.GC14707@stefanha-x1.localdomain>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
	<1482912571-3157-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6580428924105863863=="
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482912571-3157-4-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============6580428924105863863==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DIOMP1UsTsWJauNi"
Content-Disposition: inline


--DIOMP1UsTsWJauNi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 28, 2016 at 04:09:31PM +0800, Jason Wang wrote:
> +static int tun_rx_batched(struct tun_file *tfile, struct sk_buff *skb,
> +			  int more)
> +{
> +	struct sk_buff_head *queue = &tfile->sk.sk_write_queue;
> +	struct sk_buff_head process_queue;
> +	int qlen;
> +	bool rcv = false;
> +
> +	spin_lock(&queue->lock);

Should this be spin_lock_bh()?  Below and in tun_get_user() there are
explicit local_bh_disable() calls so I guess BHs can interrupt us here
and this would deadlock.

--DIOMP1UsTsWJauNi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYa6gPAAoJEJykq7OBq3PIZ2sH/0VYpR4DPRyzYO7z6UMBZwGC
gbOV4hIqlfKg3e9MWqF4ekaRGek/WuV3goEUOhXBY1gwI2NGWoowb4/wPfjCTQR0
6r6Vt78rgAsl4McgXJ6fQdH1pGgLVNZQ+/iXINjRjpFN1vYPj+vXFk0GuhDZV5ke
gNmUFs2kJ2HysCJtLjB2Fuwmspmbd6jhRNmQET5ADsiZsbi9+Lm8jYME/CESkE8h
gLaW1G3ECOkKDza9TkXx5wlq1GRUllpe0zqw6tGKQEPZLF0wu+PKHTru0vkKddX1
pmE9ukXVAJqxoP2XwWU8qXfNBjpPyZS9JAMzA3R5HuWJCQ+z3ASpGkIQMqRbs/Q=
=kLi7
-----END PGP SIGNATURE-----

--DIOMP1UsTsWJauNi--

--===============6580428924105863863==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============6580428924105863863==--
