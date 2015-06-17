From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Wed, 17 Jun 2015 00:50:44 -0700
Message-ID: <CAE4R7bDnVEq1mqUmmYMFAd9CeEbn9tTzD_UnoDKYVScT5G=QJA@mail.gmail.com>
References: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35363 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757817AbbFQHvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 03:51:05 -0400
Received: by obbgp2 with SMTP id gp2so27803744obb.2
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 00:51:04 -0700 (PDT)
In-Reply-To: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 9:11 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

[snip]

> @@ -1203,6 +1204,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>
>                 if (!(cfg->fc_nlflags & NLM_F_APPEND))
>                         fa = fa_first;
> +               else
> +                       nlflags |= NLM_F_APPEND;
>         }

The if and else parts above don't seem logically related.  Maybe you
could initialize nlflags as:

    unsigned int nlflags = cfg->fc_nlflags & (NLM_F_REPLACE|NLM_F_APPEND);

And then pass rtmsg_fib(..., nlflags) to avoid the flag test/set?
