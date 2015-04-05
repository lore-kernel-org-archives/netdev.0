From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/4] mac80211-hwsim: notify user-space about channel change.
Date: Sun, 05 Apr 2015 17:16:14 +0300
Message-ID: <552143AE.5060109@cogentembedded.com>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net
To: greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:34258 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbbDEOQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 10:16:16 -0400
Received: by lboc7 with SMTP id c7so6546391lbo.1
        for <netdev@vger.kernel.org>; Sun, 05 Apr 2015 07:16:15 -0700 (PDT)
In-Reply-To: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/4/2015 12:12 AM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>

> The goal is to allow the user-space application to properly
> filter packets before sending them down to the kernel.  This
> should more closely mimic what a real piece of hardware would
> do.

> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
>   drivers/net/wireless/mac80211_hwsim.c | 48 +++++++++++++++++++++++++++++++++++
>   drivers/net/wireless/mac80211_hwsim.h |  6 +++++
>   2 files changed, 54 insertions(+)

> diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
> index 8908be6..d0e88b2 100644
> --- a/drivers/net/wireless/mac80211_hwsim.c
> +++ b/drivers/net/wireless/mac80211_hwsim.c
> @@ -871,6 +871,52 @@ static bool hwsim_ps_rx_ok(struct mac80211_hwsim_data *data,
>   	return true;
>   }
>
> +static void mac80211_hwsim_check_nl_notify(struct mac80211_hwsim_data *data)
> +{
> +	struct sk_buff *skb;
> +	u32 center_freq = 0;
> +	u32 _portid;
> +	void *msg_head;
> +
> +	/* wmediumd mode check */
> +	_portid = ACCESS_ONCE(wmediumd_portid);
> +

    I don't think empty line is needed here...

> +	if (!_portid)
> +		return;
> +
> +	skb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> +	if (skb == NULL)

    Hm, have you run this thru scripts/checkpatch.pl? It should have 
recommended using '!skb' instead (which would have been only consistent with 
your previous code).

> +		goto err_print;
> +
> +	msg_head = genlmsg_put(skb, 0, 0, &hwsim_genl_family, 0,
> +			       HWSIM_CMD_NOTIFY);
> +	if (msg_head == NULL) {

    Same here.

[...]

WBR, Sergei
