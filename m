From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net: dsa: Fix of kernel panic in case of missing
 PHY.
Date: Tue, 09 Dec 2014 22:45:55 +0300
Message-ID: <54875173.3070504@cogentembedded.com>
References: <54873205.30401@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: Andrey Volkov <andrey.volkov@nexvision.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:65006 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbaLITp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:45:59 -0500
Received: by mail-lb0-f172.google.com with SMTP id u10so1144800lbd.3
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 11:45:57 -0800 (PST)
In-Reply-To: <54873205.30401@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/09/2014 08:31 PM, Andrey Volkov wrote:

> Fix of kernel panic in case of missing PHY.

> Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>
> ---
>   net/dsa/slave.c |   19 +++++++++++++++----
>   1 file changed, 15 insertions(+), 4 deletions(-)

> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 528380a..6f89caa 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
[...]
> @@ -555,12 +555,17 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>   	 */
>   	if (!p->phy) {
>   		p->phy = ds->slave_mii_bus->phy_map[p->port];
> -		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
> +		if(p->phy)

    Space is needed after *if*. Run your patches thru scripts/checkpatch.pl, 
it should detect such coding style issues.

> +			phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
>   				   p->phy_interface);

    This continuation line should be realigned now, to start right under 
'slave_dev' on the previous line.

[...]

WBR, Sergei
