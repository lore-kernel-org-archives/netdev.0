From: "Chris Friesen" <cfriesen@nortel.com>
Subject: question about niu linux driver behaviour
Date: Wed, 16 Sep 2009 15:13:00 -0600
Message-ID: <4AB154DC.7070305@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Santwona.Behera@sun.com, Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:59552 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583AbZIPVOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 17:14:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I've got a Sun 3320 ATCA "alonso" board with Neptune network devices.
I'm running basically 2.6.27.8, and I'm seeing some odd behaviour in the
niu driver.

My understanding is that there are four ports. 0 and 1 are XMAC links,
while 10, and 11 are BMAC links.  On our board these normally map to
eth4/5/6/7.

At boot time, if the other end for the XMAC links is not up, then we see
messages that look like:

niu 0000:08:00.0: niu: Port 0 signal bits [00000000] are not [30000000]
niu 0000:08:00.0: niu: Port 0 10G/1G SERDES Link Failed
niu 0000:08:00.1: niu: Port 1 signal bits [00000000] are not [0c000000]
niu 0000:08:00.1: niu: Port 1 10G/1G SERDES Link Failed

and the BMAC links come up as eth4/eth5.

This seems to be due to the fact that we're checking ESR_INT_SIGNALS for
ESR_INT_DET0_P0 and ESR_INT_DET0_P1, and then failing because they're
not set.  (The 10G initialization behaves similarly.)

Is this valid behaviour?  I seems fragile for successful serdes
initialization to depend on the other end of the link being up at driver
init time.

Chris
