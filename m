From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [PATCH] iwlwifi: out-of-bounds access in iwl_init_sband_channels
Date: Fri, 14 Aug 2015 04:31:55 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E7EA2CE@hasmsx107.ger.corp.intel.com>
References: <1439512532-7901-1-git-send-email-adrien+dev@schischi.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ilw@linux.intel.com" <ilw@linux.intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Adrien Schildknecht <adrien+dev@schischi.me>,
	"Berg, Johannes" <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 08/14/2015 03:36 AM, Adrien Schildknecht wrote:
> Both loops of this function compare data from the 'chan' array and then
> check if the index is valid.
> 
> The 2 conditions should be inverted to avoid an out-of-bounds access.
> 

Was that found by a static analyzer or any other automated tool, or was
that the result of your very careful review?

> Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>
> ---
>  drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c b/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
> index 21302b6..acc3d18 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
> @@ -713,12 +713,12 @@ int iwl_init_sband_channels(struct iwl_nvm_data *data,
>  	struct ieee80211_channel *chan = &data->channels[0];
>  	int n = 0, idx = 0;
>  
> -	while (chan->band != band && idx < n_channels)
> +	while (idx < n_channels && chan->band != band)
>  		chan = &data->channels[++idx];
>  
>  	sband->channels = &data->channels[idx];
>  
> -	while (chan->band == band && idx < n_channels) {
> +	while (idx < n_channels && chan->band == band) {
>  		chan = &data->channels[++idx];
>  		n++;
>  	}
> 

Looks fine - I'll pick it up.
