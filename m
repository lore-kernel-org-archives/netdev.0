From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/6] qlcnic_dcb.c : possible division by zero.
Date: Thu, 26 Feb 2015 17:22:50 +0300
Message-ID: <54EF2C3A.3020505@cogentembedded.com>
References: <1424901403-6458-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ameen Ali <ameenali023@gmail.com>, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424901403-6458-1-git-send-email-ameenali023@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/26/2015 12:56 AM, Ameen Ali wrote:

> Whenever there is a division it is usually worthwhile to
> add some belt'n'braces code to ensure that cnt != 0, otherwise
> a machine signal can occur.

> Signed-off-by : Ameen Ali <Ameenali023@gmail.com>
> ---
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> index a72bcdd..c1d5e48 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> @@ -822,7 +822,7 @@ qlcnic_dcb_get_pg_tc_cfg_tx(struct net_device *netdev, int tc, u8 *prio,
>   		if (temp->valid && (pg == temp->pgid))
>   			cnt++;
>   	}
> -
> +	if(cnt != 0)

    Space needed after *if*. Please run your patches thru 
scripts/checkpatch.pl before posting.

>   	tc_cfg->bwg_percent = (100 / cnt);

    What happens to 'tc_cfg->bwg_percent' when cnt == 0?
    You need to indent this line by an extra TAB, since it's a part of the 
*if* statment now.

>   	*bw_per = tc_cfg->bwg_percent;
>   }

WBR, Sergei
