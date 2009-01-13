From: Michal Soltys <soltys@ziu.info>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Tue, 13 Jan 2009 09:43:10 +0100
Message-ID: <496C541E.6080203@ziu.info>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>	<200901122038.05199.denys@visp.net.lb>	<Pine.LNX.4.64.0901122052510.4748@ask.diku.dk>	<200901122201.19616.denys@visp.net.lb>	<496C198A.4060502@trash.net> <20090112232811.46100689@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:24979 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083AbZAMInN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 03:43:13 -0500
In-Reply-To: <20090112232811.46100689@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 13 Jan 2009 05:33:14 +0100
> 
> Even with NO_HZ the regular kernel won't schedule timers sooner
> than HZ. I believe it caused regressions so it was disabled.

While making manpage(s) for hfsc (I'll post it soon), I've done some 
tests - setting trivial hfsc class, essentially as a tbf emulator, 
produces impressive amount of timer interrupts.

tc qdisc add dev eth0 root handle 1:0 hfsc default 1
tc class add dev eth0 parent 1:0 classid 1:1 hfsc rt m2 300mbit

nc -u dst.host.com 54321 </dev/zero
nc -l -p 54321 >/dev/null

319: 42124229   0  HPET_MSI-edge  hpet2 (before)
319: 42436214   0  HPET_MSI-edge  hpet2 (after ~10s.)

That's over 30,000 per second. CPU load is another thing in this case 
(still easily tolerable by cheap dual core amd cpu), but interrupt rate 
goes easily far beyond HZ mark. Of course both 'tickless system' and 'hr 
timers' must be enabled.
