From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 2/7] bna: Tx and Rx Optimizations
Date: Fri, 7 Dec 2012 10:46:22 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70E5@saturn3.aculab.com>
References: <1354835868-27016-1-git-send-email-rmody@brocade.com> <1354835868-27016-3-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <bhutchings@solarflare.com>,
	<adapter_linux_open_src_team@brocade.com>
To: "Rasesh Mody" <rmody@brocade.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60224 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932073Ab2LGKzO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 05:55:14 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31597-10 for <netdev@vger.kernel.org>;
 Fri,  7 Dec 2012 10:55:08 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1354835868-27016-3-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  #define BNA_QE_INDX_ADD(_qe_idx, _qe_num, _q_depth)			\
>  	((_qe_idx) = ((_qe_idx) + (_qe_num)) & ((_q_depth) - 1))
> 
> +#define BNA_QE_INDX_INC(_idx, _q_depth)					\
> +do {									\
> +	(_idx)++;							\
> +	if ((_idx) == (_q_depth))					\
> +		(_idx) = 0;						\
> +} while (0)
> +

If q_depth has to be a power of 2 (implied by BNA_QE_IND_ADD())
then you should mask in BNA_QE_INDX_INC() to save the conditional.
Or just:
#define BNA_QE_INDX_INC(_idx, _q_depth) BNA_QE_INDX_ADD(_idx, 1, _q_depth)

	David
