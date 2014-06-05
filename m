From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] bridge: Fix incorrect judgment of promisc
Date: Thu, 5 Jun 2014 11:03:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17257C08@AcuExch.aculab.com>
References: <1401965851-6449-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: 'Toshiaki Makita' <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46408 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750723AbaFELE0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 07:04:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11157-07 for <netdev@vger.kernel.org>;
 Thu,  5 Jun 2014 12:04:17 +0100 (BST)
In-Reply-To: <1401965851-6449-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita
> br_manage_promisc() incorrectly expects br_auto_port() to return only 0
> or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/bridge/br_if.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index a08d2b8..6a07a40 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -153,7 +153,7 @@ void br_manage_promisc(struct net_bridge *br)
>  			 * This lets us disable promiscuous mode and write
>  			 * this config to hw.
>  			 */
> -			if (br->auto_cnt <= br_auto_port(p))
> +			if (br->auto_cnt <= !!br_auto_port(p))
>  				br_port_clear_promisc(p);
>  			else
>  				br_port_set_promisc(p);

Why not the less confusing:
			if (br->auto_cnt || br_auto_port(p))
and reverse the then/else lines?

	David
