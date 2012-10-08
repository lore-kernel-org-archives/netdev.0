From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [RFC:PATCH 3.6.0-] net/ipconfig: Extend ipconfig retries to device
 open
Date: Mon, 08 Oct 2012 13:38:57 +0100
Message-ID: <5072C961.3030807@st.com>
References: <1349365123-25826-1-git-send-email-srinivas.kandagatla@st.com> <20121007.001156.294004123796199582.davem@davemloft.net>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:60477 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752476Ab2JHMkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 08:40:45 -0400
In-Reply-To: <20121007.001156.294004123796199582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/12 05:11, David Miller wrote:
> From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
> Date: Thu,  4 Oct 2012 16:38:43 +0100
>
>> This patch adds retries to ipconfig at device open, the reason to do
>> this is: Lets say If some mdio bus driver decide to use defered probe
>> when it does not find any phys on the bus. The same mdio-bus driver is
>> re-probed as part of lateinit calls. However ipconfig also fits into
>> lateinit calls, so if ipconfig is called before the re-probe of mdio-bus
>> driver, the mac driver will fail to find a valid PHY on the mdio-bus.
> Real device drivers for real devices should not probe using late
> initcalls.
I agree,
Let me summarize what I did try.

I wanted to use "Defered Probe Feature" which went in 3.4 kernel to
solve a sequencing issue.
So modified Mdio-driver accordingly, mdio-driver decided to defer its
probe for the first-time when It could not detect any PHY's on the BUS.
(second time) device probe is actually called in lateinit call sequence
by "Defered Probe Code".

>
> The whole point of late initcalls is that you can be certain that they
> run after such things.
Yes I agree.
>
> Fix the virus not the symptom.
>
> I'm not applying this patch.

This use-case here is totally possible given that mdio bus can be
independent driver to MAC driver and Vice-versa.
So there might be situation at times that mdio bus driver might depend
on MAC driver, like in my case MAC driver has to setup itself to provide
clock to PHY's on MDIO bus before mdio-bus driver scan phys.
So using "Defered probe" feature for mdio-bus drivers will never work.

Thanks,
srini
