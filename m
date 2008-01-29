From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: sky2: tx hang on dual-port Yukon XL when rx csum disabled
Date: Tue, 29 Jan 2008 10:26:25 -0500
Message-ID: <479F45A1.2030407@cybernetics.com>
References: <479E2247.8080109@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:4969 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754907AbYA2P0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 10:26:24 -0500
In-Reply-To: <479E2247.8080109@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tony Battersby wrote:
> "iperf -c 192.168.1.1" never finishes, but "iperf -c 192.168.2.1" does
> finish.  Press Ctrl-C to abort the hung iperf.  Ping 192.168.1.1 does
> not respond.  Ping 192.168.2.1 does respond, but each ping has almost
> exactly 1 second latency (the latency should be < 1 ms).
>
>   

Update: after triggering the problem, the ping latency on the interface
that still responds is the same as the ping interval.  The default ping
interval is 1 second, so in my initial test I was seeing a 1 second ping
latency.  If I do "ping -i 2 192.168.2.1", then each ping takes 2
seconds to receive the response.  If I do "ping -i 5 192.168.2.1", then
each ping takes 5 seconds to receive the response.  This implies that
the network stack doesn't realize that it received the ping reply until
it goes to send another ping.

Hope that helps.

Tony Battersby
Cybernetics

