From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Tue, 17 Jul 2007 21:03:20 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Eric Dumazet" <dada1@cosmosbay.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:41874 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934008AbXGQTzt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 15:55:49 -0400
Content-class: urn:content-classes:message
In-reply-to: <469CE9E5.7040003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>> I managed to reproduce a crash with ipcomp, will try to 
> fix it later.
> >>>       
> >> Yes, I can confirm this.
> >> After disabling IPComp the crashes went away.
> >>     
> > The crash happens in xfrm_bundle_ok when walking the bundle upwards
> > following xfrm_dst->u.next. The loop should be stopped when
> > xfrm_dst->u.next == first (the topmost xfrm_dst), but it points to
> > NULL instead. I'm pretty sure the attached patch is responsible,
> > it breaks XFRM's assumption that dst->next and xfrm_dst->u.next are
> > the same pointer and xfrm_dst now shares the next pointer with
> > rcu_head.next in struct dst_entry.
> >
> > Eric, could you look into this please?
> 
> I fixed it myself. Daniel, can you please test this patch?

Many thanks Patrick!!!
I tested it and found it working!

No more crashes with IPComp and smaller PMTUs.
But the "pmtu discovery on SA ESP/..." messages don't disappear.

Daniel
