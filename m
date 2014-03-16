From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: net_ratelimit() pr_warn()s in 802.3ad
 mode
Date: Sun, 16 Mar 2014 09:45:15 -0700
Message-ID: <1394988315.9668.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:61570 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbaCPQpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 12:45:17 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so4581124pdj.23
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 09:45:17 -0700 (PDT)
In-Reply-To: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-16 at 17:29 +0100, Veaceslav Falico wrote:

> @@ -1559,7 +1560,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>  		}
>  
>  		/* check if any partner replys */
> -		if (best->is_individual) {
> +		if (best->is_individual && net_ratelimit()) {

This looks odd, to mix conditions that are not of the same domain.

Have you considered using pr_warn_ratelimited() ?

>  			pr_warn("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
>  				best->slave ?
>  				best->slave->bond->dev->name : "NULL");
> @@ -2080,7 +2081,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
