From: Laszlo Attila Toth <panther@balabit.hu>
Subject: cassini driver skb->truesize bug
Date: Tue, 04 Dec 2007 15:19:07 +0100
Message-ID: <475561DB.7080404@balabit.hu>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:39764 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbXLDOTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 09:19:10 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 17AE2C130B
	for <netdev@vger.kernel.org>; Tue,  4 Dec 2007 15:19:09 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

we got the following message:
SKB BUG: Invalid truesize (376) len=514, sizeof(sk_buff)=248

It only occurs on larger traffic (at speed 100 Mbps: always), but  not 
when downloading a small web page.

In cas_rx_process_pkt() the the skb's truesize is only set via skb_put()
but it is not used if there are fragments, also skb->len is increased by
the fragment's size, but the truesize member is unchanged. I compared it 
to the implementation in e1000 where  all of the len, datalen and 
trusize members are increased.

If I modify the code to add the fragment's size to the truesize member, 
the driver allocates all available memory after a while.

Regards,
Attila
