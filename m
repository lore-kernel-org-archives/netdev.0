From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Fri, 11 May 2012 15:08:37 +0300
Message-ID: <20120511120836.GA4637@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
 <1336671977.14220.26.camel@zakaz.uk.xensource.com>
 <20120510184246.GE14647@redhat.com>
 <1336726800.23818.33.camel@zakaz.uk.xensource.com>
 <1336733892.23818.69.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202Ab2EKMIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2012 08:08:38 -0400
Content-Disposition: inline
In-Reply-To: <1336733892.23818.69.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 11, 2012 at 11:58:12AM +0100, Ian Campbell wrote:
> On Fri, 2012-05-11 at 10:00 +0100, Ian Campbell wrote:
> > I'm seeing copy_ubufs called in my remote NFS test, which I don't
> > think I expected -- I'll investigate why this is happening today. 
> 
> It's tcp_transmit_skb which can (conditionally) call skb_clone
> (backtrace below)

Interesting. I didn't realise we clone skbs on data path:
tcp_write_xmit calls tcp_transmit_skb with clone_it flag.
Could someone comment on why we need to clone on good path
like this?

-- 
MST
