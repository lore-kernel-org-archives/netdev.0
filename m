From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/5] bonding: convert to list API and replace
 bond's custom list
Date: Wed, 31 Jul 2013 11:37:17 -0700
Message-ID: <20130731113717.32f48d71@nehalam.linuxnetplumber.net>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
	<1375283553-32070-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	fubar@us.ibm.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41615 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178Ab3GaShV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 14:37:21 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so1067421pdc.5
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 11:37:21 -0700 (PDT)
In-Reply-To: <1375283553-32070-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Jul 2013 17:12:29 +0200
Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 390061d..80e288c 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -143,10 +143,13 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
>   */
>  static inline struct port *__get_first_port(struct bonding *bond)
>  {
> +	struct slave *first_slave;
> +
>  	if (bond->slave_cnt == 0)
>  		return NULL;
> +	first_slave = bond_first_slave(bond);

As Jay said, it would be be better to have bond_first_slave return
NULL (if no slaves), and eliminate slave_cnt. It would also fix
a race here between slave_cnt and all slave's being removed.
