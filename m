From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 09:31:14 +0200
Message-ID: <516BACC2.7060400@onera.fr>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com> <1365879412-9541-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:32869 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3DOHfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 03:35:47 -0400
In-Reply-To: <1365879412-9541-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On 04/13/2013 08:56 PM, Willem de Bruijn wrote:
> [...]
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3311,7 +3311,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>   		 * so keep the shared tx_flags and only
>   		 * store software time stamp
>   		 */
> -		skb->tstamp = ktime_get_real();
> +		orig_skb->tstamp = skb->tstamp = ktime_get_real();
>   	}

You said that "the orig_skb is usually freed shortly after
skb_tstamp_tx is called".

So i suppose that if you had coded it, that's because this orig_skb is 
the one that is given to the skb destructor. So when you call 
__packet_set_timestamp, in tpacket_destruct_skb, you get this timestamp 
? Am i right ?


Why we couldn't call
*skb_hwtstamps(orig_skb) = *skb_hwtstamps(skb) = *hwtstamps;
in order to get the hardware timestamping too ?

Thank for your help.

Paul.
