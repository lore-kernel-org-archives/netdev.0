From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/9] s390: netiucv driver fixes
Date: Wed, 06 Sep 2006 11:13:56 -0400
Message-ID: <44FEE5B4.9070003@pobox.com>
References: <200609061705.14737.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62682 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751379AbWIFPOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:14:05 -0400
To: fpavlic@de.ibm.com
In-Reply-To: <200609061705.14737.fpavlic@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fpavlic@de.ibm.com wrote:
> [PATCH 2/9] s390: netiucv driver fixes
> 
> From: Frank Pavlic <fpavlic@de.ibm.com>
>  - missing lock initialization added
>         - avoid duplicate iucv-interfaces to the same peer
>         - rw-lock added for manipulating the list of
>           defined iucv connections
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> ---
> 
>  drivers/s390/net/netiucv.c |   80 
> +++++++++++++++++++++++++++++++++++---------
>  1 files changed, 64 insertions(+), 16 deletions(-)
> 
> 05eebe4adf2ad6b442b3dc0bd34ccc5863299efb
> diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
> index 5d6e6cb..d7d1cc0 100644
> --- a/drivers/s390/net/netiucv.c
> +++ b/drivers/s390/net/netiucv.c
> @@ -112,7 +112,12 @@ struct iucv_connection {
>  /**
>   * Linked list of all connection structs.
>   */
> -static struct iucv_connection *iucv_connections;
> +struct iucv_connection_struct {
> + struct iucv_connection *iucv_connections;
> + rwlock_t iucv_rwlock;
> +};

Please submit a patch very soon that runs scripts/Lindent over all the 
s390 net drivers.  These drivers don't comply with 
Documentation/CodingStyle.

	Jeff



