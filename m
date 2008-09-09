From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours:
 ip6_dst_lookup_tail NULL crash
Date: Tue, 09 Sep 2008 13:52:40 -0700 (PDT)
Message-ID: <20080909.135240.193707624.davem@davemloft.net>
References: <20080909113215.GB5991@hmsreliant.think-freely.org>
	<20080909143105.GA24239@2ka.mipt.ru>
	<20080909153955.GD5991@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, rdenis@simphalempin.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753471AbYIIUwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 16:52:47 -0400
In-Reply-To: <20080909153955.GD5991@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 9 Sep 2008 11:39:55 -0400

> On Tue, Sep 09, 2008 at 06:31:05PM +0400, Evgeniy Polyakov wrote:
> > This should be (*dst)->neighbour, isn't it?
> > 
> Dang it, yes it should.  Sorry.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied with the following commit message.  I'll queue
this up for -stable as well.

Thanks!

ipv6: Fix OOPS in ip6_dst_lookup_tail().

This fixes kernel bugzilla 11469: "TUN with 1024 neighbours:
ip6_dst_lookup_tail NULL crash"

dst->neighbour is not necessarily hooked up at this point
in the processing path, so blindly dereferencing it is
the wrong thing to do.  This NULL check exists in other
similar paths and this case was just an oversight.

Also fix the completely wrong and confusing indentation
here while we're at it.

Based upon a patch by Evgeniy Polyakov.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
