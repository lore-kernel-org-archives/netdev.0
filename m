From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 16:01:06 -0700
Message-ID: <1149116466.4022.5.camel@rh4>
References: <20060531045811.GA6977@gondor.apana.org.au>
 <20060530.221117.85394939.davem@davemloft.net>
 <1149110429.3078.5.camel@rh4>
 <20060531.170908.46214247.davem@davemloft.net>
 <20060601002525.GA19220@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:59151 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S965076AbWFAAkk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 20:40:40 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060601002525.GA19220@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-01 at 10:25 +1000, Herbert Xu wrote:
> On Wed, May 31, 2006 at 05:09:08PM -0700, David Miller wrote:
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Wed, 31 May 2006 14:20:29 -0700
> > 
> > > David, So do we want to fix this issue as proposed by Herbert to replace
> > > tx_lock with xmit_lock? It seems quite straightforward to do. For this
> > > change to work, netpoll also needs to be fixed up a bit to check for
> > > LLTX before getting the xmit_lock.
> > 
> > Oh yes, netpoll needs changes, thanks for noticing that.
> 
> Why does it need to change? The idea is to take the LLTX flag off tg3
> after the conversion to xmit_lock.

Oh, I thought your idea was to keep the LLTX and just replace tx_lock
with xmit_lock in tg3. But I suppose we can also clear LLTX, remove the
tx_lock in hard_start_xmit and convert the rest to avoid changing
netpoll.


