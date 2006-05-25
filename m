From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Thu, 25 May 2006 13:50:11 -0700
Message-ID: <20060525135011.470dc3dd@localhost.localdomain>
References: <A975FFC51622704CBEAB749E263D1799015540B5@mail01.student.main.ntu.edu.sg>
	<20060525.132350.39157903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ZHOU0022@ntu.edu.sg, baruch@ev-en.org, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46547 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030407AbWEYUuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:50:23 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060525.132350.39157903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 13:23:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
> Date: Thu, 25 May 2006 16:30:48 +0800
> 
> > Yes, I agree. Actually the main contribution of TCP Veno is not in
> > this AI phase. No matter the ABC is added or not, TCP Veno can
> > always improve the performance over wireless networks, according to
> > our tests.
> 
> It seems to me that the wireless issue is seperate from congestion
> control.
> 
> The key is to identify "true loss" due to overflow of intermediate
> router queues, vs. "false loss" which is due to temporary radio
> signal interference.

Is it really possible to tell the two apart.  Also, a lot of times when
an access point is overloaded, performance is killed because of congestion
overload. 

> This determination is a job for the loss detection in the generic ACK
> processing code in tcp_input.c, not for a congestion control algorithm.
> The congestion control algorithm uses the "true loss" information to
> make congestion control decisions.
> 
> We already have code that tries to make this differentiation, in the
> form of FRTO, and your techniques can likely be placed there as well.

The general idea of resetting cwnd to an estimate of capacity seems to
be a general feature of Westwood, Veno, Compound and Africa. Also FreeBSD
does the same thing, but they don't have a cool name.
