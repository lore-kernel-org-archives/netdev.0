From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V2 2/3] qdisc: bulk dequeue support for
 qdiscs with TCQ_F_ONETXQUEUE
Date: Sat, 06 Sep 2014 05:55:49 -0700
Message-ID: <1410008149.11872.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140904125247.4108.8132.stgit@dragon>
	 <20140904125438.4108.38160.stgit@dragon>
	 <1409837383.26422.113.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140905102815.157fda5a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:51498 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaIFMzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 08:55:52 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so23938893pad.18
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 05:55:52 -0700 (PDT)
In-Reply-To: <20140905102815.157fda5a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-05 at 10:28 +0200, Jesper Dangaard Brouer wrote:

> 
> So, I cannot see if it is a TSO packet via the skb_is_gso(skb) check?
> Will skb->len be the length of the full TSO packet size?


There is no difference between a TSO and GSO packet. They are what we
call a GSO packet.

The difference lies on the device ability to perform TSO.

If device is not able to send a TSO packet, packet is segmented by the
core networking stack.
