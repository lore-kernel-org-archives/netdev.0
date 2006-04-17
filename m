From: George Nychis <gnychis@cmu.edu>
Subject: want to randomly drop packets based on percent
Date: Mon, 17 Apr 2006 03:38:33 -0400
Message-ID: <444345F9.4090100@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.81]:50307 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP
	id S1750726AbWDQHgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 03:36:23 -0400
To: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

I'm using the 2.4.32 kernel with madwifi and iproute2 version 
2-2.6.16-060323.tar.gz

I wanted to insert artificial packet loss based on a percent so i found:
network emulab qdisc could do it, so i compiled support into the kernel 
and tried:
tc qdisc change dev eth0 root netem loss .1%

however i keep getting the error
RTNETLINK answer: Invalid argument

I am not sure how to go about solving this problem for now, so if anyone 
has any suggestions i'd greatly appreciate it.

I really only need to drop random packets being forwarded through 
ip_forward ... however randomly dropping any packet based on a % is 
sufficient so I figured netem would be great.

So in the meantime I figured I would try to insert packet loss in 
ip_forward.c by generating a random number and dropping based on that. 
I could goto drop; depending on the number in the function int 
ip_forward(struct sk_buff *skb)

But then I ran into the problem of properly seeding the random number 
generator... srand(time(0)) is one way... however time() returns 
seconds, therefore i would drop multiple packets in a single second if I 
used this method which is very undesirable.  What is the proper way to 
generate a random number here?

Thanks!
George
