From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH v2 3/4] ppp_mppe: cleanup kernel log messages
Date: Tue, 21 May 2013 11:40:26 -0700
Message-ID: <1369161626.2143.45.camel@joe-AO722>
References: <1369160304-31967-1-git-send-email-jorge@dti2.net>
	 <1369160304-31967-3-git-send-email-jorge@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: jorge@dti2.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369160304-31967-3-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 20:18 +0200, Jorge Boncompte [DTI2] wrote:
> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> 
> - Consolidate log messages, print PPP unit number where available.
> - Changes error or warning messages to correct log level.
> - Use _ratelimited() functions for messages triggered by network packets.
[]
> diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
[]
> @@ -178,7 +178,8 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
>  		setup_sg(sg_out, state->session_key, state->keylen);
>  		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
>  					     state->keylen) != 0) {
> -    		    printk(KERN_WARNING "mppe_rekey: cipher_encrypt failed\n");
> +			net_warn_ratelimited("%s[%d]: crypto_blkcipher_encrypt "
> +					     "failed\n", __func__, state->unit);

Please don't split formats across multiple lines.

			net_warn_ratelimited("%s[%d]: crypto_blkcipher_encrypt failed\n",
					     __func__, state->unit);

is just fine.

> @@ -314,8 +314,7 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
>  			sprintf(mkey + i * 2, "%02x", state->master_key[i]);
>  		for (i = 0; i < sizeof(state->session_key); i++)
>  			sprintf(skey + i * 2, "%02x", state->session_key[i]);
> -		printk(KERN_DEBUG
> -		       "%s[%d]: keys: master: %s initial session: %s\n",
> +		printk(KERN_DEBUG "%s[%d]: keys: master: %s initial session: %s\n",
>  		       debugstr, unit, mkey, skey);

this could probably use:
	%*ph, (int)sizeof(state->session_key), state->session_key

>  	}
>  
> @@ -387,9 +386,9 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
[]
> +		net_err_ratelimited("%s[%d]: osize too small! "
> +				    "(have: %d need: %d)\n", __func__,
> +				    state->unit, osize, isize + MPPE_OVHD + 2);

another split format, please coalesce.

etc...

