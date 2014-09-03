From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V3] qdisc: validate frames going through the
 direct_xmit path
Date: Wed, 3 Sep 2014 18:17:22 +0200
Message-ID: <20140903181722.02fca893@redhat.com>
References: <20140903114841.19969.22671.stgit@dragon>
	<20140903155508.23813.75407.stgit@dragon>
	<1409760507.26422.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbaICQRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 12:17:31 -0400
In-Reply-To: <1409760507.26422.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 03 Sep 2014 09:08:27 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-09-03 at 17:56 +0200, Jesper Dangaard Brouer wrote:
[...]
> > Also handle the error situation where dev_hard_start_xmit() could
> > return a skb list, and does not return dev_xmit_complete(rc) and
> > falls through to the kfree_skb(), in that situation it should
> > call kfree_skb_list().
> 
> It seems that in this situation, we will return rc = -ENETDOWN,
> I do not think this is the right error code. Not sure if that matters...

Yes, I noticed, but we have always returned this, in these kind of err
situations, so I didn't want to change that behavior.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
