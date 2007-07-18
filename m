From: David Miller <davem@davemloft.net>
Subject: Re: IPSec freeze
Date: Wed, 18 Jul 2007 01:58:42 -0700 (PDT)
Message-ID: <20070718.015842.90122319.davem@davemloft.net>
References: <469BB50C.10203@trash.net>
	<469CE9E5.7040003@trash.net>
	<3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, dada1@cosmosbay.com
To: Daniel.Beschorner@facton.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754164AbXGRI6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 04:58:43 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Date: Tue, 17 Jul 2007 21:03:20 +0200

> > >>> I managed to reproduce a crash with ipcomp, will try to 
> > fix it later.
> > >>>       
> > >> Yes, I can confirm this.
> > >> After disabling IPComp the crashes went away.
> > >>     
> > > The crash happens in xfrm_bundle_ok when walking the bundle upwards
> > > following xfrm_dst->u.next. The loop should be stopped when
> > > xfrm_dst->u.next == first (the topmost xfrm_dst), but it points to
> > > NULL instead. I'm pretty sure the attached patch is responsible,
> > > it breaks XFRM's assumption that dst->next and xfrm_dst->u.next are
> > > the same pointer and xfrm_dst now shares the next pointer with
> > > rcu_head.next in struct dst_entry.
> > >
> > > Eric, could you look into this please?
> > 
> > I fixed it myself. Daniel, can you please test this patch?
> 
> Many thanks Patrick!!!
> I tested it and found it working!

Thank you for testing.
