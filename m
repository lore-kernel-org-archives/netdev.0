From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [PATCH net-next] net/mlxfw: select CONFIG_XZ_DEC
Date: Tue, 30 May 2017 12:28:26 +0300
Message-ID: <e172a668-eae0-4d94-4e59-40cbc100418e@mellanox.com>
References: <20170530092628.1306028-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0070.outbound.protection.outlook.com ([104.47.0.70]:10752
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751025AbdE3J2g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 05:28:36 -0400
In-Reply-To: <20170530092628.1306028-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 12:26 PM, Arnd Bergmann wrote:
> The new mlxfw code fails to build without the xz library:
>
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.o: In function `mlxfw_mfa2_xz_dec_run':
> :(.text.mlxfw_mfa2_xz_dec_run+0x8): undefined reference to `xz_dec_run'
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.o: In function `mlxfw_mfa2_file_component_get':
> :(.text.mlxfw_mfa2_file_component_get+0x218): undefined reference to `xz_dec_init'
> :(.text.mlxfw_mfa2_file_component_get+0x2c0): undefined reference to `xz_dec_end'
>
> This adds a Kconfig 'select' statement for it, which is also what
> the other user of that library has.
>
> Fixes: 410ed13cae39 ("Add the mlxfw module for Mellanox firmware flash process")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/mellanox/mlxfw/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlxfw/Kconfig b/drivers/net/ethernet/mellanox/mlxfw/Kconfig
> index 56b60ac7bc34..2b21af8a2b1d 100644
> --- a/drivers/net/ethernet/mellanox/mlxfw/Kconfig
> +++ b/drivers/net/ethernet/mellanox/mlxfw/Kconfig
> @@ -4,3 +4,4 @@
>  
>  config MLXFW
>          tristate "mlxfw" if COMPILE_TEST
> +	select XZ_DEC

Thanks!

Acked-by: Yotam Gigi <yotamg@mellanox.com>
