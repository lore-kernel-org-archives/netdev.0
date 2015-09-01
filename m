From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 10/21] net: rbridge: add rbr_node management
 function
Date: Tue, 1 Sep 2015 21:30:49 +0300
Message-ID: <55E5EED9.20201@cogentembedded.com>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
 <1441122196-11662-11-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: William Dauchy <william@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36617 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbIASaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:30:52 -0400
Received: by lbcao8 with SMTP id ao8so4721088lbc.3
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:30:50 -0700 (PDT)
In-Reply-To: <1441122196-11662-11-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2015 06:43 PM, Ahmed Amamou wrote:

> rbr_node are used to save distant Rbridges information
> they are use by local Rbridge to take routing decision
> this patch add get/put/free/find/del  function to rbr_node to
> avoid freeing a rbr_node that is still in use for routing
>
> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> Signed-off-by: William Dauchy <william@gandi.net>
> ---
>   net/bridge/rbr.c         | 35 +++++++++++++++++++++++++++++++++++
>   net/bridge/rbr_private.h | 23 +++++++++++++++++++++++
>   2 files changed, 58 insertions(+)

[...]
> diff --git a/net/bridge/rbr_private.h b/net/bridge/rbr_private.h
> index 9166a8b..186e454 100644
> --- a/net/bridge/rbr_private.h
> +++ b/net/bridge/rbr_private.h
> @@ -44,7 +44,30 @@ struct rbr {
[...]
> +static inline void rbr_node_put(struct rbr_node *rbr_node)
> +{
> +	if (rbr_node) {
> +		if (unlikely(atomic_dec_and_test(&rbr_node->refs)))

    Could fold both 'if's into one and avoid {} altogether.

> +			rbr_node_free(rbr_node);
> +	}
> +}
> +

MBR, Sergei
