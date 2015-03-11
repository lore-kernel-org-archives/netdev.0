From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 1/2] net: implement dma cache skb allocator
Date: Wed, 11 Mar 2015 17:06:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAFB82F@AcuExch.aculab.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com>
 <1426009384-11544-2-git-send-email-_govind@gmx.com>
 <54FF5521.5000007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: 'Alexander Duyck' <alexander.h.duyck@redhat.com>,
	"Govindarajulu Varadarajan" <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:64363 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbbCKRHu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:07:50 -0400
In-Reply-To: <54FF5521.5000007@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck
...
> The question I would have is do you actually need to have the 9k
> buffer?  Does the hardware support any sort of scatter-gather receive?
> If so that would be preferable as the 9k allocation per skb will have
> significant overhead when you start receiving small packets.
...

You don't necessarily need true scatter gather.

A lot of ethernet MAC continue long frames into the buffer
associated with the next ring entry.
So if you fill the ring with (say) 2k buffers you 'just' have
to piece the fragments together when a long frame is received.

I used to use a single 64k buffer split into 128 buffers of 512
bytes each (last was actually smaller for alignment).
All receive frames were copied into (the equivalent of) an skb
that was allocated after the receive completed.
The aligned copy (including the leading and trailing padding)
didn't actually cost enough to worry about.
(Without TCP checksum offload the data was heading for the cache.)

	David
