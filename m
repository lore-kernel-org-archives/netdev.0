From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 22 May 2007 15:36:36 -0700 (PDT)
Message-ID: <20070522.153636.115911096.davem@davemloft.net>
References: <E1Hq2kM-0000ID-00@gondolin.me.apana.org.au>
	<OF9ABCD08D.2CD1B193-ON872572E3.007A6FC1-882572E3.007ACE1A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rdreier@cisco.com
To: xma@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758737AbXEVWgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 18:36:35 -0400
In-Reply-To: <OF9ABCD08D.2CD1B193-ON872572E3.007A6FC1-882572E3.007ACE1A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <xma@us.ibm.com>
Date: Tue, 22 May 2007 15:22:35 -0700

> > Yep, for any NIC that supports SG but not TSO then software GSO will
> > be a big win.  When the NIC doesn't support SG then the win is mostly
> > offset by the need to copy the packet again.
> >
> > Cheers,
> > --
> 
>       We could avoid packet copy by allocating number of 64K/MTU skb
> buffers instead of one big 64K buffer size. Is it a possible approach?

I think you misunderstand the problem.

If the device does not support scatter gather, it is impossible to
avoid the copy.

SKB's from TSO are composed of discontiguous page chunks represented
by the skb_shared_info() array.  These can come either from sendmsg()
user data (which the kernel fills into a per-socket data page which is
reallocated once filled), or from sendfile() page cache pages.

Therefore, there has to be a copy somewhere to be able to give
that packet to a non-scatter-gather device.
