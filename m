From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] wireless: iwlwifi: use bool instead of int
Date: Wed, 04 Oct 2017 09:26:45 -0700
Message-ID: <1507134405.4434.10.camel@perches.com>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
         <20171004155700.18048-2-christoph@boehmwalder.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Christoph =?ISO-8859-1?Q?B=F6hmwalder?=
        <christoph@boehmwalder.at>, johannes.berg@intel.com,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004155700.18048-2-christoph@boehmwalder.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-04 at 17:56 +0200, Christoph Böhmwalder wrote:
> Change a usage of int in a boolean context to use the bool type instead, as it
> makes the intent of the function clearer and helps clarify its semantics.
> 
> Also eliminate the if/else and just return the boolean result directly,
> making the code more readable.
> 
> Signed-off-by: Christoph Böhmwalder <christoph@boehmwalder.at>
> ---
>  drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
> index b7cd813ba70f..0eb815ae97e8 100644
> --- a/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
> +++ b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
> @@ -267,14 +267,12 @@ int iwl_phy_db_set_section(struct iwl_phy_db *phy_db,
>  }
>  IWL_EXPORT_SYMBOL(iwl_phy_db_set_section);
>  
> -static int is_valid_channel(u16 ch_id)
> +static bool is_valid_channel(u16 ch_id)
>  {
> -	if (ch_id <= 14 ||
> -	    (36 <= ch_id && ch_id <= 64 && ch_id % 4 == 0) ||
> -	    (100 <= ch_id && ch_id <= 140 && ch_id % 4 == 0) ||
> -	    (145 <= ch_id && ch_id <= 165 && ch_id % 4 == 1))
> -		return 1;
> -	return 0;
> +	return (ch_id <= 14 ||
> +	       (36 <= ch_id && ch_id <= 64 && ch_id % 4 == 0) ||
> +	       (100 <= ch_id && ch_id <= 140 && ch_id % 4 == 0) ||
> +	       (145 <= ch_id && ch_id <= 165 && ch_id % 4 == 1));
>  }

This might be more intelligble as separate tests

static bool is_valid_channel(u16 ch_id)
{
	if (ch_id <= 14)
		return true;

	if ((ch_id % 4 == 0) &&
	    ((ch_id >= 36 && ch_id <= 64) ||
	     (ch_id >= 100 && ch_id <= 140)))
		return true;

	if ((ch_id % 4 == 1) &&
	    (chid >= 145 && ch_id <= 165))
		return true;

	return false;
}

The compiler should produce the same object code.
