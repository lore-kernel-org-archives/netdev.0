From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 2/3] pktgen: give user result when disable vlan/svlan
Date: Thu, 15 May 2014 12:00:31 +0200
Message-ID: <5374903F.6040202@redhat.com>
References: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com> <1400147197-22445-2-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Francesco Fondelli <francesco.fondelli@gmail.com>,
	netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbaEOKAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 06:00:46 -0400
In-Reply-To: <1400147197-22445-2-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2014 11:46 AM, Hangbin Liu wrote:
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>   net/core/pktgen.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index dcf367f..1809bdf 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -1573,8 +1573,7 @@ static ssize_t pktgen_if_write(struct file *file,
>   			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
>   			pkt_dev->svlan_id = 0xffff;
>
> -			if (debug)
> -				pr_debug("VLAN/SVLAN turned off\n");
> +			sprintf(pg_result, "OK: VLAN/SVLAN turned off");

I think that might break user scripts as pg_result is copied to user
space, and currently only expected to return 'OK: svlan_id=%u' if it
was actually successful. Unfortunately, scripts that might only check
for 'OK' in the string could make wrong assumptions later on.

>   		}
>   		return count;
>   	}
> @@ -1629,8 +1628,7 @@ static ssize_t pktgen_if_write(struct file *file,
>   		} else {
>   			pkt_dev->svlan_id = 0xffff;
>
> -			if (debug)
> -				pr_debug("SVLAN turned off\n");
> +			sprintf(pg_result, "OK: SVLAN turned off");

Ditto.

>   		}
>   		return count;
>   	}
>
