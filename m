From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: don't use debug flag
Date: Mon, 9 Jul 2007 16:26:17 -0500
Message-ID: <20070709212617.GM4457@austin.ibm.com>
References: <20070709.174521.-1300522077.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:49010 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbXGIV0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 17:26:21 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l69LQI6O032245
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 17:26:18 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l69LQIRT476966
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 17:26:18 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l69LQI09001476
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 17:26:18 -0400
Content-Disposition: inline
In-Reply-To: <20070709.174521.-1300522077.kouish@swc.toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 05:45:21PM +0900, Ishizaki Kou wrote:
> GDTDCEIDIS flag is defined that it is for debug and should not be used.

!? Certainly, my spec doesn't say anything like this;
I don't know of any other way of turning off the descriptor 
chain end interrupt; leaving it on hurts performance in a big way.

I get the following TX performance numbers:

pkt sz       rate w/o patch      rate w/patch
(bytes)      (Mbits/sec)         (Mbits/sec)
-------      ----------          ---------
400            503                 353
200            239                  88
100            122                  44
 60             73                  26

That's not quite a 3x performance degradation.

In addition, with your patch, the number of interrupts jumps
from just about zero, to about 55K/second. From what I can tell, 
this huge interrupt rate eats up all the CPU cycles, which is
why the performance drops so drasically.

> We met some troubles on Celleb platform by setting this flag.
>  -network does not recover after ifconfig down, then up operations.

Can you be more specific?  I can't imagine why this flag would
have anything to do with ifdown/ifup. The device open/close 
routines should reset all hardware state; this shouldn't make
any difference. (It doesn't for me, at least).  

--linas
