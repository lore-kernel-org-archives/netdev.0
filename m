From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 19 Jun 2007 12:04:20 -0400
Message-ID: <1182269060.4968.45.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
	 <1181904575.4102.31.camel@localhost>
	 <1182129521.4092.77.camel@debian.sh.intel.com>
	 <1182179770.4063.26.camel@localhost>
	 <1182219120.4092.143.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:54231 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbXFSQEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 12:04:23 -0400
Received: by an-out-0708.google.com with SMTP id d31so418035and
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 09:04:23 -0700 (PDT)
In-Reply-To: <1182219120.4092.143.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-19-06 at 10:12 +0800, Zhu Yi wrote:

> Mine was much simpler. We don't need to
> consider the wireless dynamic priority change case at this time. Just
> tell me what you suppose the driver to do (stop|start queue) when the
> hardware PHL is full but PHH is empty?

I already responded to this a few emails back.
My suggestion then was:
Pick between a timer and a number of packets X transmitted, whichever
comes first. [In e1000 for example, the opening strategy is every time
32 packets get transmitted, you open up]. 
In the case of wireless, pick two numbers XHH and XHL with XHL < XHH.
The timers would be similar in nature (THH > THL). All these variables
are only valid if you shutdown the ring. 
So in the case HL shuts down the ring, you fire THL. If either XHL
packets are transmitted or THL expires, you netif_wake.
Did that make sense?

BTW, this thread is going back and forth on the same recycled
arguements. As an example, i have responded to this specific question.
Can we drop the discussion?

cheers,
jamal

