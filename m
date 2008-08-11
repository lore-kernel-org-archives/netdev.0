From: Andrew Gallatin <gallatin@myri.com>
Subject: LRO restructuring?
Date: Mon, 11 Aug 2008 09:30:33 -0400
Message-ID: <48A03EF9.9090602@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Brice Goglin <brice@myri.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1935 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751511AbYHKNbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 09:31:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

You mentioned in the recent "Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI
initiator" thread that you were planning to restructure LRO to
preserve headers so as to make forwarding possible without totally
disabling LRO.

For lro_receive_frags() based LRO, it would be ideal to locate the
header in place in the frag via the mac_hdr argument to the
get_frag_header() callback.  Eg, I'm hoping that neither the driver
nor the LRO module will need to allocate extra memory per frame and
copy the headers to it in the common case when forwarding is
not enabled.  That would add quite a bit of overhead.

With respect to hardware LRO and headers:  Would it be possible
to notify the driver via some sort of callback whether the headers
are required?  I think most hardware LRO implementations are going
to collapse the headers, and having the option to fallback to software
LRO for forwarding might be needed for those devices which will throw
away the intermediate headers.

Last, have you considered simply allowing "inexact" forwarding, where
the ingress NIC is doing LRO and the egress nic is doing TSO?  You
loose exact framing information (eg, what you emit might not be framed
exactly as you receive it), but you can still do filtering, and the
host overhead is very low.

Thanks,

Drew
