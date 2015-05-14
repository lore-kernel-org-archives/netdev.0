From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Thu, 14 May 2015 14:26:14 +0800
Message-ID: <20150514062614.GA6320@gondor.apana.org.au>
References: <20150514020316.1635.50870.stgit@ahduyck-vm-fedora22>
 <20150514032833.GF3853@gondor.apana.org.au>
 <55543D4F.8050306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, steffen.klassert@secunet.com,
	tgraf@suug.ch, davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36820 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbENG0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 02:26:20 -0400
Content-Disposition: inline
In-Reply-To: <55543D4F.8050306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 11:14:39PM -0700, Alexander Duyck wrote:
> 
> The fact is I am not all that familiar with the vti code and just
> started crawling through it a few days ago, but it seems like it is
> overwriting the skb->mark value with the i_key to determine which
> policy to use.  The code prior to commit df3893c176e9 ("vti: Update
> the ipv4 side to use it's own receive hook.") was saving the old
> skb->mark, overwriting it, and then restoring it after a call to
> xfrm4_policy_check.  After that commit it was letting
> skb_scrub_packet in vti_rcv_cb clear the mark and it was just
> dropped.

Steffen, why is vti touching skb->mark at all? This is supposed
to be a field used by user-space to control a packet as it moves
inside the kernel.  Seconding it for other purposes looks very
wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
