From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: Re: [PATCH] cxgb4: implement ndo_set_vf_rate()
Date: Tue, 6 Jun 2017 12:13:03 +0530
Message-ID: <20170606064301.GA12125@chelsio.com>
References: <1496667860-11703-1-git-send-email-ganeshgr@chelsio.com>
 <BLUPR0701MB2004623B3F087A8213B2AEBF8DCA0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>,
        "kumaras@chelsio.com" <kumaras@chelsio.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:14891 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdFFGnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 02:43:07 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR0701MB2004623B3F087A8213B2AEBF8DCA0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, June 06/05/17, 2017 at 14:03:14 +0000, Mintz, Yuval wrote:
> > +	pktsize = be16_to_cpu(port_rpl.u.info.mtu);
> > +	/* subtract ethhdr size and 4 bytes crc since, f/w appends it */
> > +	pktsize = pktsize - sizeof(struct ethhdr) - 4;
> > +	/* subtract ipv4 hdr size, tcp hdr size to get typical IPv4 MSS size */
> > +	pktsize = pktsize - sizeof(struct iphdr) - sizeof(struct tcphdr);
> > +	/* configure Traffic Class for rate-limiting */
> > +	ret = t4_sched_params(adap, SCHED_CLASS_TYPE_PACKET,
> > +			      SCHED_CLASS_LEVEL_CL_RL,
> > +			      SCHED_CLASS_MODE_CLASS,
> > +			      SCHED_CLASS_RATEUNIT_BITS,
> > +			      SCHED_CLASS_RATEMODE_ABS,
> > +			      pi->port_id, class_id, 0,
> > +			      max_tx_rate * 1000, 0, pktsize);
> 
> Does it mean you're achieving throughput limitation by
> limiting the PP/s?
By bits/sec.
