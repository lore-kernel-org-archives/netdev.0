From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 15/29] ieee80211 Renamed ieee80211_hdr to ieee80211_hdr_4addr
Date: Tue, 13 Sep 2005 19:45:23 -0400
Message-ID: <200509131945.23126.flamingice@sourmilk.net>
References: <43275856.7010305@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ieee80211-devel@lists.sourceforge.net,
        James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <43275856.7010305@linux.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch plus patch 5 looks very similar to my management frame patch 
except..

On Tuesday 13 September 2005 18:53, James Ketrenos wrote:
> @@ -552,6 +577,17 @@ struct ieee80211_authentication {
>  	struct ieee80211_info_element info_element[0];
>  } __attribute__ ((packed));
>
> +struct ieee80211_disassoc {
Add alias for deauthentication frame here?

> +	struct ieee80211_hdr_3addr header;
> +	u16 reason_code;
If we do not append _code to "status", why append _code to "reason"?

> +	struct ieee80211_info_element info_element[0];
> +} __attribute__ ((packed));
> +
> +struct ieee80211_probe_request {
> +	struct ieee80211_hdr_3addr header;
> +	struct ieee80211_info_element info_element[0];
> +} __attribute__ ((packed));
> +
>  struct ieee80211_probe_response {
>  	struct ieee80211_hdr_3addr header;
>  	u32 time_stamp[2];
> @@ -560,14 +596,25 @@ struct ieee80211_probe_response {
>  	struct ieee80211_info_element info_element[0];
>  } __attribute__ ((packed));
>
> -struct ieee80211_assoc_request_frame {
> +/* Alias beacon for probe_response */
> +#define ieee80211_beacon ieee80211_probe_response
> +
> +struct ieee80211_assoc_request {
> +	struct ieee80211_hdr_3addr header;
> +	u16 capability;
> +	u16 listen_interval;
> +	struct ieee80211_info_element info_element[0];
> +} __attribute__ ((packed));
> +
> +struct ieee80211_reassoc_request {
> +	struct ieee80211_hdr_3addr header;
>  	__le16 capability;
>  	__le16 listen_interval;
>  	u8 current_ap[ETH_ALEN];
>  	struct ieee80211_info_element info_element[0];
>  } __attribute__ ((packed));
>
> -struct ieee80211_assoc_response_frame {
> +struct ieee80211_assoc_response {
>  	struct ieee80211_hdr_3addr header;
>  	__le16 capability;
>  	__le16 status;
