From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 4/5] net/netlabel: Add kmalloc NULL tests
Date: Thu, 30 Jul 2009 10:32:20 -0400
Message-ID: <200907301032.20318.paul.moore@hp.com>
References: <Pine.LNX.4.64.0907301610230.8734@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751928AbZG3Oc3@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0907301610230.8734@ask.diku.dk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 30 July 2009 10:10:54 am Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
>
> The test on map4 should be a test on map6.

...

> Signed-off-by: Julia Lawall <julia@diku.dk>
>
> ---
>  net/netlabel/netlabel_kapi.c        |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index 3ff6f32..6ce0020 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -151,7 +151,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
>  			addr6 = addr;
>  			mask6 = mask;
>  			map6 = kzalloc(sizeof(*map6), GFP_ATOMIC);
> -			if (map4 == NULL)
> +			if (!map6)
>  				goto cfg_unlbl_map_add_failure;
>  			map6->type = NETLBL_NLTYPE_UNLABELED;
>  			ipv6_addr_copy(&map6->list.addr, addr6);

Another good find, although I would suggest changing it to the following to 
stay consistent with the rest of the function:

		map6 = kzalloc(...);
		if (map6 == NULL)
			goto ...;

-- 
paul moore
linux @ hp
