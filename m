From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix arp_validate on bonds inside a bridge
Date: Thu, 06 May 2010 00:35:23 -0700 (PDT)
Message-ID: <20100506.003523.214214350.davem@davemloft.net>
References: <17907.1272935182@death.nxdomain.ibm.com>
	<20100504.161815.71114704.davem@davemloft.net>
	<20100505133301.GA18493@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36314
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755741Ab0EFHfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:35:17 -0400
In-Reply-To: <20100505133301.GA18493@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Wed, 5 May 2010 15:33:01 +0200

> If either of the ptype_all or ptype_base_predecap[] method is
> preferred, I'll be happy to re-work the patch. I just thought
> performance had bigger priority here.

Well, let's do some thinking.

If there are any ptype_all[] entries at all, processing of every
packet will be expensive.

Also, the ptype_base_predecap[] is unlikely to have any entries
unless bonding is on in this special mode.  But if it is, we
can accept a little bit of extra overhead.

So we can address all of this without adding undue overhead for people
not using this stuff, by simply having an atomic counter which shows
how many ptype_all[] or ptype_base_predecap[] entries exist.

And at the top level we test that __read_mostly atomic variable before
traversing the ptype_all[] and ptype_base_predecap[] lists.

That should address all of the issues.
