From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 15:05:28 -0700
Message-ID: <1179266728.25622.46.camel@dell>
References: <adad517zk2r.fsf@cisco.com> <200705130800.44595.ak@suse.de>
 <adatzuerr47.fsf@cisco.com>
 <20070515.131840.52167955.davem@davemloft.net>
 <adatzudq06l.fsf@cisco.com> <1179265719.25622.40.camel@dell>
 <adaps51pzg8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, ak@suse.de,
	krkumar2@in.ibm.com, "netdev" <netdev@vger.kernel.org>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4016 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbXEOVRP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 17:17:15 -0400
In-Reply-To: <adaps51pzg8.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-15 at 14:08 -0700, Roland Dreier wrote:
>  > > Well, IPoIB doesn't do netif_wake_queue() until half the device's TX
>  > > queue is free, so we should get batching.  However, I'm not sure that
>  > > I can count on a fudge factor ensuring that there's enough space to
>  > > handle everything skb_gso_segment() gives me -- is there any reliable
>  > > way to get an upper bound on how many segments a given gso skb will
>  > > use when it's segmented?
>  > 
>  > Take a look at tg3.c.  I use (gso_segs * 3) as the upper bound.
> 
> Thanks for the pointer... I noticed that code, but could you tell me
> where the "* 3" comes from?
> 
For each gso_seg, there will be a header and the payload may span 2
pages for 1500-byte packets.  We always assume 1500-byte packets because
the buggy chips do not support jumbo frames.

