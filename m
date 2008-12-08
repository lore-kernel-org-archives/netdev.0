From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 07/29] wimax: basic API: kernel/user messaging, rfkill
	and reset
Date: Mon, 08 Dec 2008 21:01:39 +0100
Message-ID: <1228766499.22164.123.camel@johannes.berg>
References: <cover.1228759689.git.inaky@linux.intel.com>
	<e4e92ac65c4617b40d8ed79c416392cde7e51534.1228759689.git.inaky@linux.intel.com>
	(sfid-20081208_201019_065351_1949CB8F)
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1057993172=="
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <e4e92ac65c4617b40d8ed79c416392cde7e51534.1228759689.git.inaky@linux.intel.com>
	(sfid-20081208_201019_065351_1949CB8F)
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org


--===============1057993172==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-fF6jW4fbxwMWQYPGiOpg"


--=-fF6jW4fbxwMWQYPGiOpg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-12-08 at 11:09 -0800, Inaky Perez-Gonzalez wrote:

> +struct wimax_pipe *wimax_pipe_add(struct wimax_dev *wimax_dev,
> +				  const char *name)
> +{
> +	int result;
> +	struct device *dev =3D wimax_dev_to_dev(wimax_dev);
> +	struct wimax_pipe *pipe;
> +
> +	d_fnstart(3, dev, "(wimax_dev %p name %s)\n", wimax_dev, name);
> +	result =3D -ENOMEM;
> +	pipe =3D kzalloc(sizeof(*pipe), GFP_KERNEL);
> +	if (pipe =3D=3D NULL) {
> +		dev_err(dev, "cannot allocate pipe '%s': %d\n",
> +			name, result);
> +		goto error_kzalloc;
> +	}

> +struct sk_buff *wimax_pipe_msg_alloc(struct wimax_dev *wimax_dev,
> +				     const void *msg, size_t size,
> +				     gfp_t gfp_flags)
> +{
> +	int result;
> +	struct device *dev =3D wimax_dev->net_dev->dev.parent;
> +	void *genl_msg;
> +	struct sk_buff *skb;
> +
> +	result =3D -ENOMEM;
> +	skb =3D genlmsg_new(nla_total_size(size), gfp_flags);
> +	if (skb =3D=3D NULL)
> +		goto error_new;

> +int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *=
info)
> +{
> +	int result;
> +	struct wimax_dev *wimax_dev;
> +	struct device *dev;
> +	struct nlmsghdr *nlh =3D info->nlhdr;
> +	void *msg_buf;
> +	size_t msg_len;
> +
> +	might_sleep();
> +	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
> +	result =3D -EPERM;
> +	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +		goto error_perm;

perms check?

> +	result =3D -ENODEV;
> +	wimax_dev =3D wimax_dev_get_by_genl_info(info);
> +	if (wimax_dev =3D=3D NULL)
> +		goto error_no_wimax_dev;


> +	result =3D wimax_dev->op_msg_from_user(wimax_dev, msg_buf, msg_len, inf=
o);
> +error_noop:
> +error_not_ready:
> +	mutex_unlock(&wimax_dev->mutex);
> +error_no_data:
> +	dev_put(wimax_dev->net_dev);
> +error_no_wimax_dev:
> +error_perm:
> +	d_fnend(3, NULL, "(skb %p info %p) =3D %d\n", skb, info, result);
> +	return result;

Do you really need all the fnstart/fnend debugging everywhere? Isn't
this easily covered by ftrace nowadays? If you remove that you can very
much simplify the code by using "return -ESOMETHING" instead of jumping
to a label in many of these functions.

johannes

--=-fF6jW4fbxwMWQYPGiOpg
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJPX0fAAoJEKVg1VMiehFYkR0QALZti0Yb2Q8VsrVE67A2Ou4M
+qP/loS3OB8wlcelrdQrHTvajQYa6Wzxi5mFfbyQQ5r3bP1JjLo3lZPJEBuTSxfP
LeWHcb8V/Zanh+Z5gqjSFDVZEpV9+KoREJgxNNqkWCCGli3CkHTkdaNCCIqJm/e/
l0TCRE3U2DaEEJU8pIoZZ6ZuydgtIFapJgBiTRI0rkLc7+p4hXaFijjxKTqIhxq0
4kgHDcl0oHoxVdx+pZe2lN5m76WUQneAuPkM1ENSV/JFpJMUaFq1+XGwLq0/AmEm
vBL2f76KAWsWtRVDHAyMjH1drRSKYwUE+efr4MINJwKLvsZu8qtMs96cABBmKBs8
H9/qMlZUSk3AidNYCoHLzzmeZhapV/JWOybBIosx+rzFh6p/UPHDEGIi0ridimQ+
RLkvJ9MKx65/irJ01krHLNP0vYWIKvWhfD6rIoh1IfFt5JDD/SEeZKb8GcP3iC+q
C2M+MP65bfy8Lj7/U3T0QYT5kQ5L39AFF1NdcNPikO7ulGO41GDvV9ZoXxkZ9lqI
2BgXY736layPh5yORUexwb5GXBo+ARoZWL3FliwQnQpYJddWA/wANMTP81hiiaNk
boSfB4Jxk8gyi5ZjyqRQ8rZ9+KmLSCAwGyg46B9rgMVKLmQ+vCIZxgarSoZssRvd
Dnccqu7WTPZDnsF1suci
=7YsY
-----END PGP SIGNATURE-----

--=-fF6jW4fbxwMWQYPGiOpg--


--===============1057993172==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
wimax mailing list
wimax@linuxwimax.org
http://www.linuxwimax.org/mailman/listinfo/wimax

--===============1057993172==--
