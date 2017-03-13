From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 5/7] ath9k: of: Use the clk API to get the reference clock
 rate
Date: Mon, 13 Mar 2017 23:17:58 +0100
Message-ID: <cc9f5389-7284-1269-7cf4-9ff2a2d692c0@gmail.com>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
 <1489439116-4233-5-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Crispin <john@phrozen.org>, Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alban <albeu@free.fr>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35960 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752786AbdCMWSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:18:03 -0400
In-Reply-To: <1489439116-4233-5-git-send-email-albeu@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2017 10:05 PM, Alban wrote:
> @@ -573,6 +575,12 @@ static int ath9k_of_init(struct ath_softc *sc)
>
>  	ath_dbg(common, CONFIG, "parsing configuration from OF node\n");
>
> +	clk = clk_get(sc->dev, "ref");
> +	if (!IS_ERR(clk)) {
> +		ah->is_clk_25mhz = (clk_get_rate(clk) == 25000000);

One trivial thing: you don't need these extra braces.


> +		clk_put(clk);
> +	}
