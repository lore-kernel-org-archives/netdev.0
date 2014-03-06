From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: correctly handle out of range parameters for
 lp_interval
Date: Thu, 06 Mar 2014 20:15:45 +0100
Message-ID: <5318C961.4000606@redhat.com>
References: <1394129030-9947-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, fubar@us.ibm.com,
	vfalico@redhat.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394129030-9947-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/2014 07:03 PM, Sasha Levin wrote:
> We didn't correctly check cases where the value for lp_interval is not
> within the legal range due to a missing table terminator.
> 
> This would let userspace trigger a kernel panic by specifying a value out
> of range:
> 
> 	echo -1 > /sys/devices/virtual/net/bond0/bonding/lp_interval
> 
> Introduced by commit "bonding: add infrastructure for an option API".
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  drivers/net/bonding/bond_options.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index 23f3655..4d35cdc 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -124,6 +124,7 @@ static struct bond_opt_value bond_resend_igmp_tbl[] = {
>  static struct bond_opt_value bond_lp_interval_tbl[] = {
>  	{ "minval",  1,       BOND_VALFLAG_MIN | BOND_VALFLAG_DEFAULT},
>  	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
> +	{ NULL,      -1,      0},	
>  };
>  
>  static struct bond_option bond_opts[] = {
> 
Thanks!

One note though, the commit that introduces the problem is not that one.
It's 4325b374f84e59226851636df946f2500d0bfeba ("bonding: convert
lp_interval to use the new option API"), after that's corrected you
can add my:

Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
