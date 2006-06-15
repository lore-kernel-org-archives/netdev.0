From: xeb@mail.ru
Subject: Re: driver for pptp
Date: Thu, 15 Jun 2006 13:49:29 +0400
Message-ID: <E1FqoTh-0005q5-00.xeb-mail-ru@f19.mail.ru>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from f19.mail.ru ([194.67.57.49]:19463 "EHLO f19.mail.ru")
	by vger.kernel.org with ESMTP id S932405AbWFOJta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 05:49:30 -0400
Received: from mail by f19.mail.ru with local
	id 1FqoTh-0005q5-00
	for netdev@vger.kernel.org; Thu, 15 Jun 2006 13:49:29 +0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for critique.

>Please read Documentation/SubmittingPatches (and CodingStyle) and submit your kernel patch to netdev.

OK.


>1) why wasn't it possible to use the PPPoX infrastructure of the kernel which is already being used by PPPoE ?  Or at least model it somehow similar to the existing PPPoE/PPPoX infrastructure?

I agree, I will rebuild module.


>2) why are you using a timer for asynchronous processing of GRE frames?
   First of all, why does it have to happen asynchronously at all?
   Secondly, why using a timer when there's nothing time related (or do
   I miss something)?  If deferred, out-of-context execution is
   required, there are other primitives such as tasklets.

Because it is the mechanism of processing reordered packets. On timeout (i.e. there was a loss of packets) buffered packets continue to be processed. It for reduction of traffic if client is under firewall which may reorder packets.


>3) you conflict with the ip_gre.c genric GRE encapsulation driver.  this
   is because both want to reigster a proto handler for GRE.  Ideally,
   there needs to be another demultiplex between the GRE protocl and its
   users.  The code registered for GRE would look at the packet and
   determine whether e.g. it is a PPTP GRE packet and then pass it on to
   the pptp module.

I contacted to the developer ip_gre.c and it has told too most but while there are no results.


4) your code doesn't look nonlinear skb clean

Please give me more comments.


5) why did you chose to implement  /dev/pptp rather than a socket family
   like the existing pppox/pppoe code?

I agree, I will rebuild module.


