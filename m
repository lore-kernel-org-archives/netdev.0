From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH net-next 3/3] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Thu, 17 Aug 2017 15:55:51 +0100
Message-ID: <20170817145551.GI5539@stefanha-x1.localdomain>
References: <KL1P15301MB00086EF58514BFD08F66B6C4BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="0NB0lE7sNnW8+0qW"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Jorgen Hansen <jhansen@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "joe@perches.com" <joe@perches.com>,
        "linux
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <KL1P15301MB00086EF58514BFD08F66B6C4BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0NB0lE7sNnW8+0qW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 10:18:41PM +0000, Dexuan Cui wrote:
> +static u32 hvs_get_local_cid(void)
> +{
> +	return VMADDR_CID_ANY;
> +}

Interesting concept: the guest never knows its CID.  This is nice from a
live migration perspective.  Currently VMCI and virtio adjust listen
socket local CIDs after migration.

> +static bool hvs_stream_allow(u32 cid, u32 port)
> +{
> +	static const u32 valid_cids[] = {
> +		VMADDR_CID_ANY,

Is this for loopback?

> +		VMADDR_CID_HOST,
> +	};
> +	int i;
> +
> +	/* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF) is
> +	 * reserved as ephemeral ports, which are used as the host's ports
> +	 * when the host initiates connections.
> +	 */
> +	if (port > MAX_HOST_LISTEN_PORT)
> +		return false;

Without this if statement the guest will attempt to connect.  I guess
there will be no listen sockets above MAX_HOST_LISTEN_PORT, so the
connection attempt will fail.

...but hardcode this knowledge into the guest driver?

--0NB0lE7sNnW8+0qW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZla53AAoJEJykq7OBq3PIeC4H/j9lwEAGG0SNo0QPMTc/1GPJ
GAr3FlH8SyOKRETQA8LLOXM1WQM3QShqSDrl1Y37vi5IJL/VmYEJOcEBfq3EG8Ck
XPChqNq+0cp8bMRNWeLLpykzdHsato6vdO1bNr31AaFr+anH1eS6YnGmVU3DBzSd
HgCsm1q0vOL+MpGBZ7JnXkJloPSBFw3hlhBi3ccMVTxfp8qESPzjDupuYydEh086
/FxXHrbNnuQEkdiMZlo2tH+qCS/TaGE4ZVYmwVlxDdQ8EH8emPHkak+V8VZy6sT9
yASd50ogJmW1CMaaHLlpSf1gewI2ek+SzymXoNqhMWLqukq2IoIeqZOtODm2o/o=
=p8P2
-----END PGP SIGNATURE-----

--0NB0lE7sNnW8+0qW--
