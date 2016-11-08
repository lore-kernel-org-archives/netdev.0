From: Leon Romanovsky <leon@kernel.org>
Subject: Re: linux-next: manual merge of the rdma-leon-test tree with the
 net-next tree
Date: Tue, 8 Nov 2016 10:39:39 +0200
Message-ID: <20161108083939.GD4815@leon.nu>
References: <20161108130623.4b9b4403@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="KdquIMZPjGJQvRdI"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Ahern <dsa@cumulusnetworks.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Doug Ledford <dledford@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161108130623.4b9b4403@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--KdquIMZPjGJQvRdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 08, 2016 at 01:06:23PM +1100, Stephen Rothwell wrote:
> Hi Leon,
>
> Today's linux-next merge of the rdma-leon-test tree got a conflict in:
>
>   drivers/infiniband/core/roce_gid_mgmt.c
>
> between commit:
>
>   453d39329ad0 ("IB/core: Flip to the new dev walk API")
>
> from the net-next tree and commit:
>
>   e4b4d6b5d8c2 ("IB/core: Remove debug prints after allocation failure")
>
> from the rdma-leon-test tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Thanks Stephen,

Doug,
Please be aware that you will get this conflict too, since David has
different drivers/infiniband/core/roce_gid_mgmt.c file than you have.

>
> --
> Cheers,
> Stephen Rothwell
>
> diff --cc drivers/infiniband/core/roce_gid_mgmt.c
> index 3a64a0881882,c86ddcea7675..000000000000
> --- a/drivers/infiniband/core/roce_gid_mgmt.c
> +++ b/drivers/infiniband/core/roce_gid_mgmt.c
> @@@ -437,28 -434,6 +434,26 @@@ static void callback_for_addr_gid_devic
>   			  &parsed->gid_attr);
>   }
>
>  +struct upper_list {
>  +	struct list_head list;
>  +	struct net_device *upper;
>  +};
>  +
>  +static int netdev_upper_walk(struct net_device *upper, void *data)
>  +{
>  +	struct upper_list *entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
>  +	struct list_head *upper_list = data;
>  +
> - 	if (!entry) {
> - 		pr_info("roce_gid_mgmt: couldn't allocate entry to delete ndev\n");
> ++	if (!entry)
>  +		return 0;
> - 	}
>  +
>  +	list_add_tail(&entry->list, upper_list);
>  +	dev_hold(upper);
>  +	entry->upper = upper;
>  +
>  +	return 0;
>  +}
>  +
>   static void handle_netdev_upper(struct ib_device *ib_dev, u8 port,
>   				void *cookie,
>   				void (*handle_netdev)(struct ib_device *ib_dev,

--KdquIMZPjGJQvRdI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYIY9LAAoJEORje4g2clinhskP/RCIMAWbFRQ+CzQzc08lEQI4
T6MWrbIyBFoJUeEA03sr18zUnBnKZs0LVuCEYLv8kVLyqZRAnSmV2RK6UFT9mQL5
T7w98LZmVM5CFpiNr2ua81WiOeSuK6BI8419HY9CnwoGTMLs6R7/sfJS4Wmf7wfi
UHl1yn1sAvLa9TG6kSDrWFvKrIDeaFCngTc2zM+JDx7mNZx+x9fgz2FTK8HbzMex
/wLrxc1dOTFZ16TLUv71oaWPffrzgBjfmtJaAeZTkHfoFZXX5xJKCHYdhtf8zm4i
Kw0XOqWCdeajk9jxX9+Y/PcEJJvpX4xD3hEtm89We3Fc4XRNaU9xRfMjwuNYoKrw
tj52gGPDJrQlTNKMsAleI5gk4SRaPxiaouq8n/vj1hgEpfb91h4pARdviiTmbzCC
v+xIGS/iBIDABlA/j/r6sCjiwUFDMq2ZrCURWr4QrNj5u+7e8KekRDTdT8YU5n6i
PmL+L629aPxFBZsTsSAKOq0CWpNeSmVCf1tRNeJpVNpbkhmqAN+jv+gBlSzj7ljA
Nwcl7I/okK0Oa0Iw9wfFsP60agHlK6LyEMB65xsDf9GNlfsukBfNsa3MyeCwe1ds
bSHnGHRojLOOWlusBTEEMBcdQnh8eUnyVeMXYxjS/9EzqGVYa/8ql4LmnatD8rt8
vikUZWP2Yw+FKjO97WtG
=DX78
-----END PGP SIGNATURE-----

--KdquIMZPjGJQvRdI--
