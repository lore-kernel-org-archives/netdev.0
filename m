From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 14:32:13 -0700 (PDT)
Message-ID: <20140806.143213.1466007351572839621.davem@davemloft.net>
References: <CA+FuTSf96KH=JkO4Va4pfbvYHngHjxtTc33ipbif_xC9kdgaLQ@mail.gmail.com>
	<1407335823.11943.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+FuTSdnuBw4ex7Hj=ko_r0P7SqPs5gA2qcTX1tHMbo3YndMJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbaHFVcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 17:32:14 -0400
In-Reply-To: <CA+FuTSdnuBw4ex7Hj=ko_r0P7SqPs5gA2qcTX1tHMbo3YndMJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 6 Aug 2014 15:20:39 -0400

> On Wed, Aug 6, 2014 at 10:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> but also that we're going to send multiple reports back to error
>> queue.
> 
> I see. The optimization patch to queue timestamps without payload will
> mitigate that somewhat. I dropped that from the initial patchset, but
> will fix it up for net-next. It may also be possible to squash
> multiple timestamped packets on the errqueue together when they all
> have the same payload, resulting in a single (possibly no-payload)
> packet with repeating cmsgs IP_RECVERR and SCM_TIMESTAMPING. That
> would give O(1) overhead regardless of number of retransmits.

We could attach a singly linked list of small sequence number cookies
to the SKB when it gets queued up.

Upon an ACK, we need only look at the entries at the front of the list
until we see one past the cumulative ACK.

There's a little bit of work to do when SKBs are coalesced or chopped
up, but in return the timestamp indications the user gets will be very
accurate.
