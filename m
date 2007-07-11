From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [Cbe-oss-dev] [PATCH] spidernet: don't use debug flag
Date: Wed, 11 Jul 2007 16:57:38 +0900 (JST)
Message-ID: <200707110758.l6B7w1Jc026926@toshiba.co.jp>
References: <20070709212617.GM4457@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kou.ishizaki@toshiba.co.jp, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:54889 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbXGKIGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 04:06:42 -0400
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id l6B86eZv003586
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 17:06:40 +0900 (JST)
In-Reply-To: <20070709212617.GM4457@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas-san,

> > GDTDCEIDIS flag is defined that it is for debug and should not be
used.
> 
> !? Certainly, my spec doesn't say anything like this;

First, I'm sorry to say that GDTDCEDIS is for debug. It's my
misunderstanding.

My HW manual of SCC simply said that GDTDCEDIS must not be set(Is 
it same for you?).  But I don't know concretely what will go wrong 
by setting this bit.

> I don't know of any other way of turning off the descriptor 
> chain end interrupt; leaving it on hurts performance in a big way.
> 
> I get the following TX performance numbers:
> 
> pkt sz       rate w/o patch      rate w/patch
> (bytes)      (Mbits/sec)         (Mbits/sec)
> -------      ----------          ---------
> 400            503                 353
> 200            239                  88
> 100            122                  44
>  60             73                  26
> 
> That's not quite a 3x performance degradation.
> 
> In addition, with your patch, the number of interrupts jumps
> from just about zero, to about 55K/second. From what I can tell, 
> this huge interrupt rate eats up all the CPU cycles, which is
> why the performance drops so drasically.

I understand the influence for performance by setting GDTDCEDIS and
why you set this bit.

> > We met some troubles on Celleb platform by setting this flag.
> >  -network does not recover after ifconfig down, then up operations.
> 
> Can you be more specific?  I can't imagine why this flag would
> have anything to do with ifdown/ifup. The device open/close 
> routines should reset all hardware state; this shouldn't make
> any difference. (It doesn't for me, at least).  

Sorry, I have no more information that ifconfig down/up commands. All
about I know is that I met the phenomenon when GDTDCEDIS is set.

I need more investigation. Please drop the patch.

Best regards,
Kou Ishizaki
