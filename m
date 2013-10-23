From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/16] batman-adv: add bat_orig_print API function
Date: Wed, 23 Oct 2013 10:00:30 -0700
Message-ID: <1382547630.22433.23.camel@joe-AO722>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
	 <1382544303-2694-4-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0036.hostedemail.com ([216.40.44.36]:47097 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751275Ab3JWRAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 13:00:39 -0400
In-Reply-To: <1382544303-2694-4-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-23 at 18:04 +0200, Antonio Quartulli wrote:
> Each routing protocol has its own metric and private
> variables, therefore it is useful to introduce a new API
> for originator information printing.
> 
> This API needs to be implemented by each protocol in order
> to provide its specific originator table output.
[]
> +static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
> +				     struct seq_file *seq)
[]
> +	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
> +		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
> +		   "Nexthop", "outgoingIF", "Potential nexthops");

This header printf really doesn't add much with the formatting sizes.
It's pretty obscure why some of these are sized and others not sized.
For instance: %-15s doesn't refer to a mac address size.
Perhaps it'd be better to just emit the fixed string just using
BATADV_TO_MAX_VALUE.  It'd also be easier to find via grep.
