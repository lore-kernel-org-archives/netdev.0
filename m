From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH net-next v2 7/9] net: use core MTU range checking in
 misc drivers
Date: Sat, 22 Oct 2016 21:16:06 +0200
Message-ID: <20161022211606.3b5d137d@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161020175524.6184-1-jarod@redhat.com>
        <20161020175524.6184-8-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, Faisal Latif <faisal.latif@intel.com>,
        Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        Chaitra P B <chaitra.basappa@broadcom.com>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani@broadcom.com>,
        MPT-FusionLinux.pdl@broadcom.com,
        Sebastian Reichel <sre@kernel.org>,
        Felipe Balbi <balbi@kernel.org>,
        Arvid Brodin <arvid.brodin@alten.se>,
        Remi Denis-Courmont <courmisch@gmail.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:50594 "EHLO
        einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754493AbcJVTRD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 15:17:03 -0400
In-Reply-To: <20161020175524.6184-8-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct 20 Jarod Wilson wrote:
> firewire-net:
> - set min/max_mtu
> - remove fwnet_change_mtu
[...]
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
[...]
> @@ -1478,9 +1467,10 @@ static int fwnet_probe(struct fw_unit *unit,
>  	 * Use the RFC 2734 default 1500 octets or the maximum payload
>  	 * as initial MTU
>  	 */
> -	max_mtu = (1 << (card->max_receive + 1))
> -		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> -	net->mtu = min(1500U, max_mtu);
> +	net->max_mtu = (1 << (card->max_receive + 1))
> +		       - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> +	net->mtu = min(1500U, net->max_mtu);
> +	net->min_mtu = ETH_MIN_MTU;
>  
>  	/* Set our hardware address while we're at it */
>  	ha = (union fwnet_hwaddr *)net->dev_addr;

Please preserve the current behavior, i.e. do not enforce any particular
upper bound.  (Especially none based on the local link layer controller's
max_receive parameter.)

BTW, after having read RFC 2734, RFC 3146, and the code, I am convinced
that net->mtu should be initialized to 1500, not less.  But such a change
should be done in a separate patch.
-- 
Stefan Richter
-======----- =-=- =-==-
http://arcgraph.de/sr/
