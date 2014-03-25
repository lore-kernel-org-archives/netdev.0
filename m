From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of
 timestamps?
Date: Tue, 25 Mar 2014 10:39:47 -0700
Message-ID: <5331BF63.6070106@hp.com>
References: <53151E55.9000503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:22892 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755864AbaCYRjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 13:39:48 -0400
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t3425.houston.hp.com (Postfix) with ESMTP id 0ECC51DD
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 17:39:47 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id BD199139
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 17:39:47 +0000 (UTC)
In-Reply-To: <53151E55.9000503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 04:29 PM, Rick Jones wrote:
> I've been looking at some packet traces of an application looking to
> upload a Large Quantity (tm) of data to a server across the Big Bad
> Internet (tm).  They've been Linux senders, and the destination while
> supporting SACK and window scaling does not support TCP timestamps. (TCP
> timestamp support was requested of the supplier of said server many many
> months ago now.)
>
> This destination system has been issuing RSTs at seemingly random points
> in the middle of a large fraction of the attempted transfers.  In
> looking at the traces, they all seem to be variations on the theme of
> what is shown by:
>
> ftp://netperf.org/retrans_question/for_netdev.png
>
> which is a passing of ftp://netperf.org/retrans_question/for_netdev.pcap
> through tcptrace -nG and zoomed-in to the end.  I've seen this with a
> 3.2.0 kernel as the sender, have reports of it happening with whatever
> is in Fedora Core 20, and the traces above are from a 3.11.0 kernel as
> the sender.
>
> The large quantity of (likely) unnecessary retransmissions shouldn't be
> triggering a RST by the receiver, but the failures consistently show
> that and I was wondering if the (spurious) retransmissions were perhaps
> "encouraged" (so to speak) by the lack of TCP Timestamps.

I have learned why the receiving TCP has reset the connection.  It would 
seem that stack has a heuristic whereby if it receives more than 255 
retransmissions in a window it will abort the connection.

rick jones
