From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Tue, 10 May 2016 17:16:16 +0000
Message-ID: <CO2PR11MB00887DD775313A8DC3F39FA597710@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1462799963-23547-2-git-send-email-Yuval.Mintz@qlogic.com>
 <20160509.151429.403288621356878412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0144.outbound.protection.outlook.com ([157.56.110.144]:11520
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751049AbcEJRQT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 13:16:19 -0400
In-Reply-To: <20160509.151429.403288621356878412.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Date: Mon, 9 May 2016 16:19:10 +0300
> 
> > +	/* bitmap indicating which fields hold valid values */
> > +	aligned_u64 valid_bitmap;
> 
> There is absolutely no reason to use aligned_u64 here.  That type is for handling
> a specific issue in user facing APIs, which this is not.

I'm not entirely convinced this is true; If we'll not enforce the alignment
of this 64-bit field, it's possible there will be differences between 32-bit
and 64-bit machines versions of this struct.
You have to recall that this is going to be copied via DMA between PF and VF,
so they must have the exact same representation of the structure.

[If I'm wrong on the technical part here, please correct me; I vaguely
seem to recall that this was already discussed on bnx2x's implementation
of the hw-channel which also uses aligned u64 fields]
