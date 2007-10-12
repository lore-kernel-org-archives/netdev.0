From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 16:18:51 +0300
Message-ID: <200710121618.51046.a1426z@gawab.com>
References: <200710120031.42805.a1426z@gawab.com> <200710121525.44510.a1426z@gawab.com> <470F6927.9040505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.12.190.111] ([212.12.190.111]:52728 "EHLO raad.intranet"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750810AbXJLNSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 09:18:52 -0400
In-Reply-To: <470F6927.9040505@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Al Boldi wrote:
> >>>The problem is that people think they are safe with the filter table,
> >>>when in fact they need the prerouting chain to seal things.  Right now
> >>>this is only possible in the mangle table.
> >>
> >>Why do they need PREROUTING?
> >
> > Well, for example to stop any transient packets being forwarded.  You
> > could probably hack around this using mark's, but you can't stop the
> > implied route lookup, unless you stop it in prerouting.
>
> This also works fine in FORWARD with a little extra overhead.
> If you really have to save resources, you should use PREROUTING/raw
> to also avoid the creation of a connection tracking entry.

Yes sure, if you use nat.  But can you see how forcing people into splitting 
their rules across tables adds complexity.  And without ipt_REJECT patch, 
they can't even use REJECT in prerouting, which forces them to do some 
strange hacks.

IMHO, we should make things as easily configurable as possible, and as things 
stand right now, the filter-table is completely useless for 99% of 
use-cases.


Thanks!

--
Al

