From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 3/5] sctp: if we done update ssnmap, free the
 new ssnmap
Date: Thu, 07 Nov 2013 22:49:18 -0500
Message-ID: <527C5F3E.3090200@gmail.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com> <1383879310-22792-4-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f50.google.com ([209.85.128.50]:36295 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab3KHDtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 22:49:21 -0500
In-Reply-To: <1383879310-22792-4-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2013 09:55 PM, Wang Weidong wrote:
> I found that free the old parameters after update the peer parameters.
> So we should free the new ssnmap which not updated.
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/sctp/associola.c | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 2d53d4c..bca1ad1 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1223,6 +1223,10 @@ void sctp_assoc_update(struct sctp_association *asoc,
>   		}
>   	}
>
> +	/* if we don't update the ssnmap, we should free it. */
> +	if (new->ssnmap)
> +		sctp_ssnmap_free(new->ssnmap);
> +
>   	/* SCTP-AUTH: Save the peer parameters from the new assocaitions
>   	 * and also move the association shared keys over
>   	 */
>

Not necessary.  This will be done when the 'new' association is destroyed.

-vlad
