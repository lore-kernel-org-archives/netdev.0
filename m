From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: [bisected regression] e1000e: "Detected
 Hardware Unit Hang"
Date: Thu, 15 Jan 2015 10:24:49 -0800
Message-ID: <1421346289.11734.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1719052.SGOfRAJhfQ@storm> <1837410.pEGIH05mML@storm>
	 <1421342437.11734.79.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1951915.1kCMSXLj6g@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:60055 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbAOSYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:24:55 -0500
Received: by mail-ig0-f169.google.com with SMTP id z20so4530818igj.0
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 10:24:54 -0800 (PST)
In-Reply-To: <1951915.1kCMSXLj6g@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 18:37 +0100, Thomas Jarosch wrote:
> On Thursday, 15. January 2015 09:20:37 Eric Dumazet wrote:
> > > for the sake of completeness:
> > > 1: hang
> > 
> > This is weird : This should have same effect then GRO off (at most one
> > segment per packet)
> 
> I thought so, too. OTOH the code path was changed from
> "goto merge" to "return -E2BIG". I didn't look at the code
> what happens at the "merge" label.

If you leave the "goto merge", then GRO still builds big GRO packets,
using a linked list of packets.

Then because drivers do not generally support NETIF_F_FRAGLIST,
core networking code linearizes such GRO packets before reaching
ndo_start_xmit()

Check 8a29111c7ca68d928dfab58636f3f6acf0ac04f7 "net: gro: allow to build
full sized skb" for details about this.
