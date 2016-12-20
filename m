From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Tue, 20 Dec 2016 13:17:28 -0500
Message-ID: <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
References: <20161219.144848.736886978545428136.davem@davemloft.net>
 <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk>
 <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
 <20161219.203623.119653805184192345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:35220 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbcLTSRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 13:17:32 -0500
Content-Disposition: inline
In-Reply-To: <20161219.203623.119653805184192345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 08:36:23PM -0500, David Miller wrote:
 > From: Dave Jones <davej@codemonkey.org.uk>
 > Date: Mon, 19 Dec 2016 19:40:13 -0500
 > 
 > > On Mon, Dec 19, 2016 at 07:31:44PM -0500, Dave Jones wrote:
 > > 
 > >  > Unfortunately, this made no difference.  I spent some time today trying
 > >  > to make a better reproducer, but failed. I'll revisit again tomorrow.
 > >  > 
 > >  > Maybe I need >1 process/thread to trigger this.  That would explain why
 > >  > I can trigger it with Trinity.
 > > 
 > > scratch that last part, I finally just repro'd it with a single process.
 > 
 > Thanks for the info, I'll try to think about this some more.

I threw in some debug printks right before that BUG_ON.
it's always this:

skb->len=31 skb->data_len=0 offset:30 total_len:9

Shouldn't we have kicked out data_len=0 skb's somewhere before we got this far ?

	Dave
