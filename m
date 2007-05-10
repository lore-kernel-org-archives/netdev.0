From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 09:18:04 -0400
Message-ID: <1178803084.4074.48.camel@localhost>
References: <E1Hm8Ey-0006oe-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, krkumar2@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:61865 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226AbXEJNSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 09:18:10 -0400
Received: by wx-out-0506.google.com with SMTP id h31so531989wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 06:18:09 -0700 (PDT)
In-Reply-To: <E1Hm8Ey-0006oe-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-05 at 22:59 +1000, Herbert Xu wrote:
> jamal <hadi@cyberus.ca> wrote:

> 			This release qlock isn't in our source code :)

This is why i defered this to you ;-> 
For completion sake, this is how it looks like:
 
 CPU0                 CPU1
  | wait qlock         |
  |                    |
  |                    + find that return code is 0
  |                    + release qdisc running
  |                    + release qlock
  + grab qlock         + ==> outta here
  | enq pktx           |
  | call qdisc_run     |
  +  grab running
  |  deq etc
  +  release running
  + release qlock
  + ==> outta here    

I wonder how much performance improvement this give now that the extra
incursion into qdisc_restart is avoided.

cheers,
jamal

