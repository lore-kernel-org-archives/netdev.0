From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] Copy mac_len in skb_clone() as well
Date: Thu, 15 Mar 2007 19:04:36 +0300
Message-ID: <20070315160436.GA7482@ms2.inr.ac.ru>
References: <20070314130711.GA6812@localhost.sw.ru> <20070315.030235.79052031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adobriyan@sw.ru, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:37482 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1422941AbXCOQOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 12:14:00 -0400
Content-Disposition: inline
In-Reply-To: <20070315.030235.79052031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> What bug triggered that helped you discover this?  Or is it
> merely from a code audit?

I asked the same question. :-)

openvz added some another fields to skbuff and when it was found
that they are lost while clone, he tried to figure out how all this works
and looked for another examples of this kind.

As I understand, the problem can be seen only in xfrmX_tunnel_input.
If uninitialized mac_len obtained from slab is more than current head room
it could corrupt memory.

Also, it looks like the fix is incomplete. copy_skb_header() also does not
copy this field. But it will be initialized to 0 by alloc_skb in this case
and xfrmX_tunnel_input() just will not copy mac header.

Alexey



