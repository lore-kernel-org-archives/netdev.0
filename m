From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: some tc commands fail on 2.6.29-rc6-git5, works on 2.6.28.7
Date: Tue, 03 Mar 2009 20:50:28 -0600
Message-ID: <1236135028.7883.44.camel@Maple>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com>
	 <20090301165729.8e08e1d7.akpm@linux-foundation.org>
	 <49AC28FF.1040102@gmail.com>
	 <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:28983 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZCDCug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 21:50:36 -0500
In-Reply-To: <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-03 at 23:10 +0000, Joao Correia wrote:
> I have confirmed again that the exact same commands (as on the
> original message), work flawlessly on 2.6.28.7 without a hitch, and,
> AFAIK, work as intended. I have also tried the latest 2.6.29-rc6-git7
> and it still fails like on git6.

I have also reproduced this on Linus' latest 2.6.29-rc6 tree, using tc
version iproute2-ss071016 and a kernel config with all traffic control
features enabled.

The error reported by tc comes from the kernel-level check added by:

	commit c1b56878fb68e9c14070939ea4537ad4db79ffae
	Author: Stephen Hemminger <shemminger@vyatta.com>
	Date:   Tue Nov 25 21:14:06 2008 -0800

    	tc: policing requires a rate estimator

    Found that while trying average rate policing, it was possible to
    request average rate policing without a rate estimator. This results
    in no policing which is harmless but incorrect.

    Since policing could be setup in two steps, need to check
    in the kernel.

    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

I got the same error when using the tc version iproute2-ss090115 built
this evening from the public git repository.

  -- John

