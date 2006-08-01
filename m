From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Tue, 01 Aug 2006 03:56:22 +0200
Message-ID: <m3bqr5z0ah.fsf@defiant.localdomain>
References: <m3r701zgku.fsf@defiant.localdomain>
	<20060731.132324.65197403.davem@davemloft.net>
	<m3fyghz2oz.fsf@defiant.localdomain>
	<20060731.181314.27783697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48605 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1030330AbWHAB4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 21:56:25 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.181314.27783697.davem@davemloft.net> (David Miller's message of "Mon, 31 Jul 2006 18:13:14 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> hdlc_fr: logical PVC devices have no headers (plain IPv4 etc. as seen
>> by tcpdump), but they append FR headers (4 or 10 bytes long) just
>> before passing the skb to physical device.
>
> If you hooked up fr_hard_header into dev->hard_header instead of
> invoking it via pvc_xmit(), everything would be fine.

That would have to be master_device->hard_header(), but the network
stack (IP and friends) has to send packets to pvc_device.
I can't make the headers show up on pvc device - that would break
packet interface and Ethernet framing. The headers have to be
visible only on master (physical) device.

> The complexity of this function arises from the fact that it prepends
> headers of differing lengths depending upon the protocol type
> being encapsulated, and this is the problem you should aim to
> solve.

Actually I don't think there is a problem with different header
lengths. The driver indicates it wants 10 bytes and that's enough
for all cases (except Ethernet framing where it indicates and uses
14 bytes and reallocs before prepending another 10 bytes).

> Alexey, any suggestions on how to handle this kind of thing?

What's wrong with my patch?

If it can's be accepted I can just add an empty pvc->hard_header().
That won't make other drivers work reliably, though, and it's IMHO
hardly their author's fault. I don't think we've ever advertised
"hard_header_len is valid only with non-NULL hard_header".
-- 
Krzysztof Halasa
