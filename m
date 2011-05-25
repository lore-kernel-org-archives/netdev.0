From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bonding: documentation and code cleanup for resend_igmp
Date: Wed, 25 May 2011 10:19:33 -0700
Message-ID: <1306343973.8149.1556.camel@tardy>
References: <1306334642-20733-1-git-send-email-fbl@redhat.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:4903 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab1EYRTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 13:19:36 -0400
In-Reply-To: <1306334642-20733-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-25 at 11:44 -0300, Flavio Leitner wrote:
> Improves the documentation about how IGMP resend parameter
> works, fix two missing checks and coding style issues.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  Documentation/networking/bonding.txt |   13 +++++++++++--
>  drivers/net/bonding/bond_main.c      |   12 +++++++-----
>  drivers/net/bonding/bond_sysfs.c     |   10 +++++-----
>  3 files changed, 23 insertions(+), 12 deletions(-)
> 
> diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
> index 1f45bd8..683ef76 100644
> --- a/Documentation/networking/bonding.txt
> +++ b/Documentation/networking/bonding.txt
> @@ -770,8 +770,17 @@ resend_igmp
>  	a failover event. One membership report is issued immediately after
>  	the failover, subsequent packets are sent in each 200ms interval.
>  
> -	The valid range is 0 - 255; the default value is 1. This option
> -	was added for bonding version 3.7.0.
> +	The valid range is 0 - 255; the default value is 1. A value of 0
> +	prevents the IGMP membership report to be issued due the failover
> +	event.

Grammar nit - "prevents the ICMP membership report from being issued in
response to the failover event."  Or "prevents issuing of the IGMP
membership report in response to a failover event."

> +
> +	This option is useful for bonding modes balance-rr or 0,
> +	active-backup or 1, balance-tlb or 5, balance-alb or 6, which a
> +	failover can move the IGMP traffic from one slave to another.
> +	Therefore, the switch must be notified with an extra IGMP report
> +	to start forwarding the IGMP traffic over the new selected slave.

More nits.  How about (with some added guesses on my part about
direction)

This option is useful for bonding modes balance-rr (0), active-backup
(1), balance-tlb (5) and balance-alb (6), in which a failover can switch
the outgoing IGMP traffic from one slave to another.  Therefore a fresh
IGMP report must be issued to cause the switch to forward the incoming
IGMP traffic over the newly selected slave.

rick jones


