From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 19:23:30 +0100
Message-ID: <1448389410.599529.449007361.7A816A14@webmail.messagingengine.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com,
	davejwatson@fb.com, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36622 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754682AbbKXSXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:23:31 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3BE5320375
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 13:23:31 -0500 (EST)
In-Reply-To: <20151124162515.GA22266@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Nov 24, 2015, at 17:25, Florian Westphal wrote:
> Its a well-written document, but I don't see how moving the burden of
> locking a single logical tcp connection (to prevent threads from
> reading a partial record) from userspace to kernel is an improvement.
> 
> If you really have 100 threads and must use a single tcp connection
> to multiplex some arbitrarily complex record-format in atomic fashion,
> then your requirements suck.

Right, if we are in a datacenter I would probably write a script and use
all those IPv6 addresses to set up mappings a la:

for each $cpu; do
  $ip address add 2000::$host:$cpu/64 dev if0 pref_cpu $cpu
done

where ip-address would also ensure via ntuples that the packets get
routed to the correct cpu. Some management layer could then ensure
correct usage of all CPUs. This way less cross-cpu traffic is ensured
for the TCP synchronization.

I only dealt with medium to low busy RPC systems but that would be my
first approach. Would something like that make sense? Would the NxM
federation overhead between the RPC system kill this approach? This way
you could also make use of the TCP PSH flag like Eric described.

Bye,
Hannes
