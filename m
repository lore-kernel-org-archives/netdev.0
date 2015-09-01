From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 09/21] net: rbridge: add elected dtroot
Date: Tue, 1 Sep 2015 21:18:29 +0300
Message-ID: <55E5EBF5.4070100@cogentembedded.com>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
 <1441122196-11662-10-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: William Dauchy <william@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33805 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbbIASSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:18:33 -0400
Received: by lbbmp1 with SMTP id mp1so4647015lbb.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:18:32 -0700 (PDT)
In-Reply-To: <1441122196-11662-10-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/01/2015 06:43 PM, Ahmed Amamou wrote:

> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> ---
>   net/bridge/rbr.c           | 14 ++++++++++++++
>   net/bridge/rbr_private.h   |  2 ++
>   net/bridge/rbr_rtnetlink.c |  6 ++++++
>   3 files changed, 22 insertions(+)
>
> diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
> index c554743..31e72ef 100644
> --- a/net/bridge/rbr.c
> +++ b/net/bridge/rbr.c
> @@ -69,3 +69,17 @@ void br_trill_set_enabled(struct net_bridge *br, unsigned long val)
>   			br_trill_stop(br);
>   	}
>   }
> +
> +int set_treeroot(struct rbr *rbr, uint16_t treeroot)
> +{
> +	if (unlikely(!VALID_NICK(treeroot))) {
> +		pr_warn_ratelimited
> +			("rbr_set_treeroot: given tree root not valid\n");
> +		goto set_tree_root_fail;

    This seems a bit stupid. Why not *return* directly?

> +	}
> +	if (rbr->treeroot != treeroot)
> +		rbr->treeroot = treeroot;
> +	return 0;
> + set_tree_root_fail:
> +	return -ENOENT;
> +}
[...]

MBR, Sergei
