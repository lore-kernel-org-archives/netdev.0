From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 13:31:54 -0400 (EDT)
Message-ID: <20130415.133154.1066916854069237592.davem@davemloft.net>
References: <1365879412-9541-1-git-send-email-willemb@google.com>
	<5169D9C8.8010504@redhat.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B71D1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, willemb@google.com, paul.chavent@onera.fr,
	richardcochran@gmail.com, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934128Ab3DORb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:31:57 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71D1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Mon, 15 Apr 2013 10:45:55 +0100

>> > +	case TPACKET_V1:
>> > +		h1 = frame;
>> > +		h1->tp_sec = ts.tv_sec;
>> > +		h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
>> > +
>> > +		flush_dcache_page(pgv_to_page(&h1->tp_sec));
>> > +		flush_dcache_page(pgv_to_page(&h1->tp_usec));
>> 
>> Hmm, not sure, but could we also flush the dcache only once?
> 
> If it isn't a silly question, why is the dcache being flushed
> here at all?

Anything that gets written into userspace mapped pages via the
kernel linear mapping of the pages must be D-cache flushed into
order to achieve coherency on cpus that have virtually indexed
caches.
