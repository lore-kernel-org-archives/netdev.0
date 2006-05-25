From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Thu, 25 May 2006 13:23:50 -0700 (PDT)
Message-ID: <20060525.132350.39157903.davem@davemloft.net>
References: <A975FFC51622704CBEAB749E263D1799015540B5@mail01.student.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, baruch@ev-en.org, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20155
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030399AbWEYUXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 16:23:46 -0400
To: ZHOU0022@ntu.edu.sg
In-Reply-To: <A975FFC51622704CBEAB749E263D1799015540B5@mail01.student.main.ntu.edu.sg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
Date: Thu, 25 May 2006 16:30:48 +0800

> Yes, I agree. Actually the main contribution of TCP Veno is not in
> this AI phase. No matter the ABC is added or not, TCP Veno can
> always improve the performance over wireless networks, according to
> our tests.

It seems to me that the wireless issue is seperate from congestion
control.

The key is to identify "true loss" due to overflow of intermediate
router queues, vs. "false loss" which is due to temporary radio
signal interference.

This determination is a job for the loss detection in the generic ACK
processing code in tcp_input.c, not for a congestion control algorithm.
The congestion control algorithm uses the "true loss" information to
make congestion control decisions.

We already have code that tries to make this differentiation, in the
form of FRTO, and your techniques can likely be placed there as well.
