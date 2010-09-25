From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not
 equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Fri, 24 Sep 2010 20:05:57 -0700 (PDT)
Message-ID: <20100924.200557.229751150.davem@davemloft.net>
References: <bug-18952-10286@https.bugzilla.kernel.org/>
	<20100922020212.d2aaec57.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yuri@itinteg.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746Ab0IYDFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 23:05:37 -0400
In-Reply-To: <20100922020212.d2aaec57.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp_syn_retries is not an exact calculation.

It is input into a calculation which estimates how long that many
retransmits (with suitable backoff applied) will take, and that time
estimte in turn determines the time limit for when we'll kill the
connection attempt.

Feel free to update the documentation in
Documentation/networking/ip-sysctl.txt to more closely match the
behavior.

The logic is in net/ipv4/tcp_timer.c:retransmits_timed_out().
