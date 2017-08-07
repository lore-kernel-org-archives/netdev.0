From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 03/14] sctp: remove the typedef
 sctp_scope_policy_t
Date: Mon, 7 Aug 2017 09:28:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD004C7B8@AcuExch.aculab.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:60297 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752489AbdHGJ2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 05:28:50 -0400
In-Reply-To: <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 05 August 2017 13:00
> This patch is to remove the typedef sctp_scope_policy_t and keep
> it's members as an anonymous enum.
> 
> It is also to define SCTP_SCOPE_POLICY_MAX to replace the num 3
> in sysctl.c to make codes clear.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/net/sctp/constants.h | 6 ++++--
>  net/sctp/sysctl.c            | 2 +-
>  2 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
> index 922fba5..acb03eb 100644
> --- a/include/net/sctp/constants.h
> +++ b/include/net/sctp/constants.h
> @@ -341,12 +341,14 @@ typedef enum {
>  	SCTP_SCOPE_UNUSABLE,		/* IPv4 unusable addresses */
>  } sctp_scope_t;
> 
> -typedef enum {
> +enum {
>  	SCTP_SCOPE_POLICY_DISABLE,	/* Disable IPv4 address scoping */
>  	SCTP_SCOPE_POLICY_ENABLE,	/* Enable IPv4 address scoping */
>  	SCTP_SCOPE_POLICY_PRIVATE,	/* Follow draft but allow IPv4 private addresses */
>  	SCTP_SCOPE_POLICY_LINK,		/* Follow draft but allow IPv4 link local addresses */
> -} sctp_scope_policy_t;
> +};
> +
> +#define SCTP_SCOPE_POLICY_MAX	SCTP_SCOPE_POLICY_LINK

Perhaps slightly better to end the enum with:
	SCTP_SCOPE_POLICY_COUNT,	/* Number of policies */
	SCTP_SCOPE_POLICY_MAX = SCTP_SCOPE_POLICY_COUNT - 1	/* Last policy */
};

	David
