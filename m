From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Mon, 2 Jul 2012 18:30:47 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
	<1341272514-5156-2-git-send-email-jitendra.kalsaria@qlogic.com>
 <20120702.171854.1585295090835924398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:13038
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932718Ab2GCBaz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 21:30:55 -0400
In-Reply-To: <20120702.171854.1585295090835924398.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per your comments, TX ring full is not expected behavior? All I can think of increasing the TX queue to 1024 and clean-up in timer instead of interrupt?

Jiten

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Monday, July 02, 2012 5:19 PM
To: Jitendra Kalsaria
Cc: netdev; Ron Mercer; Dept-NX Linux NIC Driver
Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to potential driver errors.

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Mon,  2 Jul 2012 19:41:48 -0400

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> qlge driver was acting wrongly when considering TX ring full
> as a TX error. TX ring full is expected behavior when NIC is
> overwhelmed and is expected to happen, as far as packets are
> not lost.
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

If your driver is properly coded, this code path should never trigger,
ever.  So it is an error, and you need to fix whatever bug exists in
your driver which allows this to happen, rather than this change
here which attempts to sweep the issue under the rug.
