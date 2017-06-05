From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] cxgb4: implement ndo_set_vf_rate()
Date: Mon, 5 Jun 2017 14:03:14 +0000
Message-ID: <BLUPR0701MB2004623B3F087A8213B2AEBF8DCA0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1496667860-11703-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "nirranjan@chelsio.com" <nirranjan@chelsio.com>,
        "kumaras@chelsio.com" <kumaras@chelsio.com>
To: Ganesh Goudar <ganeshgr@chelsio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0055.outbound.protection.outlook.com ([104.47.38.55]:55552
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751372AbdFEODQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 10:03:16 -0400
In-Reply-To: <1496667860-11703-1-git-send-email-ganeshgr@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	pktsize =3D be16_to_cpu(port_rpl.u.info.mtu);
> +	/* subtract ethhdr size and 4 bytes crc since, f/w appends it */
> +	pktsize =3D pktsize - sizeof(struct ethhdr) - 4;
> +	/* subtract ipv4 hdr size, tcp hdr size to get typical IPv4 MSS size */
> +	pktsize =3D pktsize - sizeof(struct iphdr) - sizeof(struct tcphdr);
> +	/* configure Traffic Class for rate-limiting */
> +	ret =3D t4_sched_params(adap, SCHED_CLASS_TYPE_PACKET,
> +			      SCHED_CLASS_LEVEL_CL_RL,
> +			      SCHED_CLASS_MODE_CLASS,
> +			      SCHED_CLASS_RATEUNIT_BITS,
> +			      SCHED_CLASS_RATEMODE_ABS,
> +			      pi->port_id, class_id, 0,
> +			      max_tx_rate * 1000, 0, pktsize);

Does it mean you're achieving throughput limitation by
limiting the PP/s?
