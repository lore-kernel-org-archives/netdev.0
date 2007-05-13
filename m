From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Sun, 13 May 2007 08:00:44 +0200
Message-ID: <200705130800.44595.ak@suse.de>
References: <p73wszfenni.fsf@bingen.suse.de> <20070511093714.GR2012@bingen.suse.de> <adad517zk2r.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:49717 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507AbXEMGAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2007 02:00:48 -0400
In-Reply-To: <adad517zk2r.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 May 2007 13:16:44 Roland Dreier wrote:
>  > I wasn't talking about sending.
>  > 
>  > But there actually is :- TSO/GSO.
> 
> As I said before, getting multiple packets in one call to xmit would
> be nice for amortizing per-xmit overhead in IPoIB.  So it would be
> nice if the cases where the stack does GSO ended up passing all the
> segments into the driver in one go.

Well TCP does upto 64k -- that is what GSO is about.

If you want it for unrelated connections I'm not sure it would actually
work because if you have a deep TX queue already it is unlikely 
the qdisc will buffer that much. Most packet injection should
come from the individual sockets which is obviously only a single connection.

-Andi
