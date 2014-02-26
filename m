From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size
 function
Date: Wed, 26 Feb 2014 16:10:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
 <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"martin.townsend@xsilon.com" <martin.townsend@xsilon.com>
To: 'Alexander Aring' <alex.aring@gmail.com>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47943 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751301AbaBZQLL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:11:11 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32052-09 for <netdev@vger.kernel.org>;
 Wed, 26 Feb 2014 16:11:08 +0000 (GMT)
In-Reply-To: <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  net/ieee802154/6lowpan.h | 116 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 116 insertions(+)
> 
> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> index 2b835db..b6ae0bc 100644
> --- a/net/ieee802154/6lowpan.h
> +++ b/net/ieee802154/6lowpan.h
> @@ -306,6 +306,122 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
>  	*hc_ptr += len;
>  }
> 
> +static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
> +{
> +	switch (addr_mode) {
> +	case LOWPAN_IPHC_ADDR_00:
> +		return 16;
> +	case LOWPAN_IPHC_ADDR_01:
> +		return 8;
> +	case LOWPAN_IPHC_ADDR_02:
> +		return 2;
> +	default:
> +		return 0;
> +	}
> +}

The compiler will generate much better code if you index an array instead
of using a switch statement.

	David
