From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Tue, 3 Jul 2012 12:38:04 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org>
References: <20120702.171854.1585295090835924398.davem@davemloft.net>
	<5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org>
	<20120702.183826.1521103644475572622.davem@davemloft.net>
 <20120702.184134.1131493483786674336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:56130
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933032Ab2GCTiP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2012 15:38:15 -0400
In-Reply-To: <20120702.184134.1131493483786674336.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Monday, July 02, 2012 6:42 PM
>To: Jitendra Kalsaria
>Cc: netdev; Ron Mercer; Dept-NX Linux NIC Driver
>Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to potential driver errors.
>
>From: David Miller <davem@davemloft.net>
>Date: Mon, 02 Jul 2012 18:38:26 -0700 (PDT)
>
>> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>> Date: Mon, 2 Jul 2012 18:30:47 -0700
>> 
>>> As per your comments, TX ring full is not expected behavior? All I
>>> can think of increasing the TX queue to 1024 and clean-up in timer
>>> instead of interrupt?
>> 
>> Your transmit function should never be invoked when the queue is
>> full, logic elsewhere in your driver should have stopped the queue
>> therefore preventing further invocations of your transmit function
>> until you wake the queue when space is liberated in the TX ring.
>
>BTW, did it even occur to you that there is a kernel log message here
>in this code path for a reason?
>
>That log message is there because this event is unexpected and a
>driver error.

I think my patch description might have been misleading. We are not fixing a logical problem but rather a statistics reporting problem. Our transmit function is not getting called when queue is full but when we stop the queue it increment tx_error statistic and one of our customers is running a test that deliberately floods the queue causing it to periodically be stopped. The customer has not reported logical problem with the test were driver perform very well but they merely pointed out that we were incorrectly reporting the queue full condition as a tx_error.

This patch was intended to remove the line that increments the tx_error statistic when the queue is correctly stopped.
