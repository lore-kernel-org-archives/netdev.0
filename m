From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Mon, 17 Sep 2007 09:03:58 -0400
Message-ID: <1190034238.4230.113.camel@localhost>
References: <1189959274.4241.30.camel@localhost>
	 <20070916.123158.92582301.davem@davemloft.net>
	 <1189975284.4230.14.camel@localhost> <1189975939.4230.19.camel@localhost>
	 <1189977000.4230.25.camel@localhost>  <20070917102738.GA3087@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kaber@trash.net, dada1@cosmosbay.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:63705 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587AbXIQNEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 09:04:01 -0400
Received: by an-out-0708.google.com with SMTP id d31so220525and
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 06:04:00 -0700 (PDT)
In-Reply-To: <20070917102738.GA3087@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-17-09 at 14:27 +0400, Evgeniy Polyakov wrote:

> 
> How many cpu collisions you are seeing?

On 4 CPUs which were always transmitting very few - there was contention
in the range of 100 per million attempts.
Note: it doesnt matter that 4 cpus were busy, this lock is contended at
max (for all NAPI drivers i poked into) between two CPUs.

> Did I understand you right, that you replaced trylock with lock and
> thus removed collision handling and got better results?

Yes, a small one with the 4 CPUs and no irq binding. Note that in the
test cases i run, the contention for queue lock was high (since all CPUs
were busy processing traffic). 
I think as the the number of CPUs go up, this will become more
prominent. The choice is between contending for queue lock or this lock.
One lock is contended by max of two cpus, the other by N cpus. As N goes
up, you want to have more mercy on the one that is contended by N cpus.
Did that make sense?

cheers,
jamal

