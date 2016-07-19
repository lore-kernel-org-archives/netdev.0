From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net] e1000e: fix PTP on e1000_pch_lpt
	variants
Date: Tue, 19 Jul 2016 20:49:03 +0000
Message-ID: <B2E38BF8-6BB1-4904-B79B-B94B9C360F15@intel.com>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_64765BA0-C9F2-447E-832C-40372CB6AAEF";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468959902-25071-1-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_64765BA0-C9F2-447E-832C-40372CB6AAEF
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Jarod Wilson <jarod@redhat.com> wrote:

> I've got reports that the Intel I-218V NIC in Intel NUC5i5RYH systems used
> as a PTP slave experiences random ~10 hour clock jumps, which are resolved
> if the same workaround for the 82574 and 82583 is employed. Switching from
> an if to a select, because the list of NIC types could well grow further
> and we'd already have to wrap the conditionals.
>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c  
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 2b2e2f8..866fea0 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -4335,7 +4335,10 @@ static cycle_t e1000e_cyclecounter_read(const  
> struct cyclecounter *cc)
>  	systim = (cycle_t)systimel;
>  	systim |= (cycle_t)systimeh << 32;
>
> -	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
> +	switch (hw->mac.type) {
> +	case e1000_82574:
> +	case e1000_82583:
> +	case e1000_pch_lpt:
>  		u64 time_delta, rem, temp;
>  		u32 incvalue;
>  		int i;

I don't think that it is acceptable to declare local variables inside a  
switch statement quite like this. At a minimum, a new block needs to be  
opened to allow the declarations.

> @@ -4360,6 +4363,9 @@ static cycle_t e1000e_cyclecounter_read(const  
> struct cyclecounter *cc)
>  			    (rem == 0))
>  				break;
>  		}
> +		break;
> +	default:
> +		break;
>  	}
>  	return systim;
>  }

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_64765BA0-C9F2-447E-832C-40372CB6AAEF
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJXjpI+AAoJEDwO/+eO4+5ueg8P/ixxbT5M45UF7eDvjN8/ovL+
xjEgSZ+/BR0bpLGY96dHLVVrPBiGrE1qsIJM6YjhMqGmGq3vu1tiJ5HO7xJmPMou
3aG8IZTL7zibB1AKl0qi59Hd+c7kMkoIvuh7Sv0vYyRJTofKiKOB8KvNUyIyVydj
rfrjk2hLwqun2WlfxsuwLKU/xLv57P9ZiDlnvHg+g8INfT7MzAENt8KqVSy3byzK
/khEtHcMXqzYuKWiGIIitHicjBYkAlNyoMQY1Ifb2XF5wi7J/hUQHm1HP1jUrW/M
X54KnCAxExR/yxAAY0CZNRKeUDdpM9KKRYtZbmbvAAdDloCccpwDSlauFQyiLOO2
JP5Viog1UTdlk7RRlLjciEjZlv+Dx1Ge4OCyxY2FtRpaKG5gY3jJnKcgp1gtJzEa
xi4doMMRqVljW4sZxNdGeX990EVRbpVisMOBhfpS4EwAYg5KSVNNfnv7M+lt84k+
gHvhDsLiPUAznuP5JhxMFSmUZge5cnW2CSpUoRjfRX5rJ3BzP+kuec4xUNSh+P/L
581Hv6+0yU/SI/C2KoeLhgkqrDDAGTH42Ke32mpW7vZ29HMOuC6xDBw4wy1w0myS
15I2hyFdJPZ7e8jRxm0PuJaaNrxS43FlT2NrHjjixhGCfh8+I8joUvYY8pfr+nxW
qpqqQOaZkHQfw+HW+Lxv
=xE46
-----END PGP SIGNATURE-----

--Apple-Mail=_64765BA0-C9F2-447E-832C-40372CB6AAEF--
