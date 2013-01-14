From: Roger Ricardo Moore <moorer007@gmail.com>
Subject: Machine hang using YeAH Advanced TCP Congestion Control algorithm
 as default under P2P load
Date: Mon, 14 Jan 2013 10:19:21 +0000
Message-ID: <1358158761.14737.12.camel@UK6475R82934W.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36967 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756178Ab3ANKTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 05:19:24 -0500
Received: by mail-wg0-f41.google.com with SMTP id ds1so1017125wgb.2
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 02:19:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I decided to test out the YeAH Advance TCP Congestion Control algorithm
- setting it as my default (patched kernel to achieve this)

I found that on 2 different machines (i386/Pentium M/radeon/e1000 and
amd64/Core2Duo/i915/e1000e) I experienced a complete machine hang after
~5-10 minutes using a P2P client (aMule) - i.e. multiple connections
with clients over the internet, both in and out of the machine.

There was no kernel OOPS just an unrecoverable freeze with no response
to any input. Each time it required the machine to be turned off and
rebooted to regain control.

I tested the machines using stress (CPU, I/O, VM and HDD) to eliminate
other possible causes of a machine hang after time but this failed to
replicate the problem. I even copied GBs of files over my local network
using SCP and this too failed to demonstrate the problem (I presume a
TCP congestion control has negligible impact in such circumstances)

I found that reverting back to CONFIG_TCP_CONG_ADVANCED=n (and this
CUBIC w/ Reno fallback) solved my problem.

I hope this information is useful to you in solving the problems with
this feature.

Regards

Roger
