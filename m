From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: What's the benefit of large Rx rings?
Date: Sun, 22 Nov 2015 20:19:02 +0000
Message-ID: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0120.outbound.protection.outlook.com ([65.55.169.120]:24112
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752239AbbKVUv6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 15:51:58 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This might be a dumb question, but I recently touched this
and felt like I'm missing something basic -

NAPI is being scheduled from soft-interrupt contex, and it
has a ~strict quota for handling Rx packets [even though we're
allowing practically unlimited handling of Tx completions].
Given these facts, what's the benefit of having arbitrary large
Rx buffer rings? Assuming quota is 64, I would have expected
that having more than twice or thrice as many buffers could not
help in real traffic scenarios - in any given time-unit
[the time between 2 NAPI runs which should be relatively
constant] CPU can't handle more than the quota; If HW is
generating more packets on a regular basis the buffers are bound
to get exhausted, no matter how many there are.

While there isn't any obvious downside to allowing drivers to
increase ring sizes to be larger [other than memory footprint],
I feel like I'm missing the scenarios where having Ks of
buffers can actually help.
And for the unlikely case that I'm not missing anything,
why aren't we supplying some `default' max and min amounts
in a common header?

Thanks,
Yuval
