From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH net-next] liquidio: store the L4 hash of rx packets in skb
Date: Mon, 9 Jan 2017 10:45:05 -0800
Message-ID: <20170109184505.GA8756@felix.cavium.com>
References: <20170107005542.GA16278@felix.cavium.com>
 <20170108.170941.1437038681712014840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0043.outbound.protection.outlook.com ([104.47.36.43]:3072
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756330AbdAISqI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 13:46:08 -0500
Content-Disposition: inline
In-Reply-To: <20170108.170941.1437038681712014840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on Sun [2017-Jan-08 17:09:41 -0500]:
> From: Felix Manlunas <felix.manlunas@cavium.com>
> Date: Fri, 6 Jan 2017 16:55:42 -0800
> 
> >  
> > +		if (rh->r_dh.has_hash) {
> > +			u32 hash = be32_to_cpu(*(u32 *)(skb->data + r_dh_off));
> 
> Is the checksum defined to be in the first 4-bytes of the 8-byte DHLEN unit,
> or the second 4-bytes?  Is the answer to this question endian-dependent?

The hash is always in the first 4-bytes.  The location of the hash is endian
independent.  The hash itself (in its original form) is big endian.
