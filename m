From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Fri, 17 Jun 2016 12:58:34 +0300
Message-ID: <20160617095834.GA5408@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VmlJMtejgecKmNHY"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466087730-54856-9-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--VmlJMtejgecKmNHY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
> This patch mainly added icm support for RoCE. It initializes icm
> which managers the relative memory blocks for RoCE. The data
> structures of RoCE will be located in it. For example, CQ table,
> QP table and MTPT table so on.
>=20
> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> ---

<...>

> +
> +static int hns_roce_alloc_icm_pages(struct scatterlist *mem, int order,
> +				    gfp_t gfp_mask)
> +{
> +	struct page *page;
> +
> +	page =3D alloc_pages(gfp_mask, order);
> +	if (!page)
> +		return -ENOMEM;
> +
> +	sg_set_page(mem, page, PAGE_SIZE << order, 0);
> +
> +	return 0;
> +}
> +
> +static int hns_roce_alloc_icm_coherent(struct device *dev,
> +				       struct scatterlist *mem, int order,
> +				       gfp_t gfp_mask)
> +{
> +	void *buf =3D dma_alloc_coherent(dev, PAGE_SIZE << order,
> +				       &sg_dma_address(mem), gfp_mask);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	sg_set_buf(mem, buf, PAGE_SIZE << order);
> +	WARN_ON(mem->offset);
> +	sg_dma_len(mem) =3D PAGE_SIZE << order;
> +	return 0;
> +}
> +

<...>

> +
> +static void hns_roce_free_icm_pages(struct hns_roce_dev *hr_dev,
> +				    struct hns_roce_icm_chunk *chunk)
> +{
> +	int i;
> +
> +	if (chunk->nsg > 0)
> +		dma_unmap_sg(&hr_dev->pdev->dev, chunk->mem, chunk->npages,
> +			     DMA_BIDIRECTIONAL);
> +
> +	for (i =3D 0; i < chunk->npages; ++i)
> +		__free_pages(sg_page(&chunk->mem[i]),
> +			     get_order(chunk->mem[i].length));

You used alloc_pages for this allocation, so why are you using
__free_pages instead of free_pages?



--VmlJMtejgecKmNHY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXY8nKAAoJEORje4g2clinTrYP/1D9P0PVZOKdEzZAhaDZF81C
E3i3x/LsVKjNejab7ny5uOfX5DOL495+2gs3/dwpypajfywqSlbdUyedWvD8WY2N
lTml1ETBME41VHLgnJ9VVUOebrpk/FQMOH3WPYFzJoSCs1afgbl9sP9tLdbTqZak
CL7pEOcUZWwSZVvZ3hZfdsuWUWdZwQj2Z+f5kYirvsCRqeR7gyD4UYreEnR7b3KD
ODVPkgJnidrAnvB4Fyau/kuOi2vXZRO7sPiNkvhscalAKvt2b10oLEbZf62AxbvV
qJ1stHYvRPVlFR21hl1MJAfKdVzIyHxsmQV6Xd0d7AnIXPyMoTfy6w+/7lgzRFVq
0CGoQsjeBtTAEteQNJvA+y6tBfQX+giHqLuZch+H9ledAz8tqjeZ9JsDZlArOcy1
/e93S2GayTZaT4exWyIlTcmT/181cAPkKF73HgltP3LBoRJ+db0rUgikUfVRLE9+
viIpHCvGFI6uhE1B9JJh+V+pvAbLzbnHg2q0lrEdvjSMUTHkqfkFMQepcSZEdUFT
Zld/wMHMjVvGAw90FbkIbg16IjPrDSvUpnnyztHBZxdLlIT0ZD+6iU0z0QGpHmTw
VljKY2WkkLOC1hV3V5aeUyoAzhUJSnLoG/zqrao9Dq+EVUM3eb5a8jZJanwMJKam
IhcbyRm3rBlwQWtwbiVK
=4teu
-----END PGP SIGNATURE-----

--VmlJMtejgecKmNHY--
