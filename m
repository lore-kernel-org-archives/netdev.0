From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] checkpatch: suggest using eth_zero_addr() and
 eth_broadcast_addr()
Date: Sun, 19 Apr 2015 13:20:13 -0700
Message-ID: <1429474813.2947.34.camel@perches.com>
References: <1429470246-15988-1-git-send-email-mateusz.kulikowski@gmail.com>
	 <1429470246-15988-3-git-send-email-mateusz.kulikowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0027.hostedemail.com ([216.40.44.27]:52752 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752013AbbDSUUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 16:20:17 -0400
In-Reply-To: <1429470246-15988-3-git-send-email-mateusz.kulikowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-19 at 21:04 +0200, Mateusz Kulikowski wrote:
> Suggest using eth_zero_addr() or eth_broadcast_addr() if memset is used instead.

Hi Mateusz, this is OK but here are some notes:

> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -5042,6 +5042,22 @@ sub process {
[]
> +# check for memset(foo, 0x0, ETH_ALEN) that could be eth_zero_addr
> +# check for memset(foo, 0xFF, ETH_ALEN) that could be eth_broadcast_addr
> +		if ($^V && $^V ge 5.10.0 &&
> +			$line =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {

Please align the $line with the $^V above it.

> +
> +			my $ms_val = $7;
> +
> +			if ($ms_val =~ /^(0x|)0$/i) {

I've seen 0x00 many times so: /^(?:0x|)0+$/

> +				WARN("PREFER_ETH_ZERO_ADDR",
> +					  "Prefer eth_zero_addr over memset()\n" . $herecurr);

Please align to the initial open quote here:

				WARN("PREFER_ETH_ZERO_ADDR",
				     "Prefer eth_zero_addr over memset()\n" . $herecurr);

> +			} elsif ($ms_val =~ /^0xff$/i) {

255 here too so: /^(?:0xff|255)$/

> +				WARN("PREFER_ETH_BROADCAST_ADDR",
> +					  "Prefer eth_broadcast_addr() over memset()\n" . $herecurr);

Please align to open quote
