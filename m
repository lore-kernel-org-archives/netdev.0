From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Tue, 10 May 2016 18:27:04 +0000
Message-ID: <CO2PR11MB0088E129548E882E1E86D72297710@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1462799963-23547-2-git-send-email-Yuval.Mintz@qlogic.com>
	<20160509.151429.403288621356878412.davem@davemloft.net>
	<CO2PR11MB00887DD775313A8DC3F39FA597710@CO2PR11MB0088.namprd11.prod.outlook.com>
 <20160510.140643.1891656073031893382.davem@davemloft.net>
 <CO2PR11MB0088ECDC1D7A65B703E2DDE797710@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0130.outbound.protection.outlook.com ([157.56.111.130]:18621
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751277AbcEJS1I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:27:08 -0400
In-Reply-To: <CO2PR11MB0088ECDC1D7A65B703E2DDE797710@CO2PR11MB0088.namprd11.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > I'm not entirely convinced this is true; If we'll not enforce the
> > > alignment of this 64-bit field, it's possible there will be
> > > differences between 32-bit and 64-bit machines versions of this struct.
> > > You have to recall that this is going to be copied via DMA between
> > > PF and VF, so they must have the exact same representation of the structure.
> >
> > Then use properly sized types to fill in all the space in the
> > structure, that's how you guarantee layout, not aligned_u64.  Also, do not use
> the packed attribute.
> >
> > struct foo {
> > 	u32 x;
> > 	u32 y;
> > 	u64 z;
> > };
> >
> > 'z' will always be 64-bit aligned.
> 
> Perhaps my bit-numeric is a bit weak - why is it so?
> I.e., what prevents `z' from only being 32-bit aligned on a 32-bit machine?
> Isn't it possible that (&x % 8)  == 4, (&y % 8) == 0 and (&z % 8) == 4 on such a
> platform?

If struct foo were to have been allocated, would it be guaranteed to be 64-bit
aligned on a 64-bit platform and 32-bit aligned on a 32-bit platform?
Assuming it is the case, is it theoretically possible that you'd have 2 different
32-bit platforms, where on one the `z' field would be packed while on the other
it will not, introducing a 4-byte gap [assuming `foo' itself was only 32-bit aligned]?
