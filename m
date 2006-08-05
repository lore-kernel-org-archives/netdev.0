From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Packet reordering in pcap capture file
Date: Sat, 5 Aug 2006 09:21:54 -0700
Message-ID: <20060805092154.040e57e1@localhost.localdomain>
References: <44D448A6.6020803@cs.cornell.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19338 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932606AbWHEQWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 12:22:10 -0400
To: Alan Shieh <ashieh@cs.cornell.edu>
In-Reply-To: <44D448A6.6020803@cs.cornell.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 05 Aug 2006 03:28:38 -0400
Alan Shieh <ashieh@cs.cornell.edu> wrote:

> Hi everyone,
> 
> I sometimes see packets stored out of order in pcap files that generated 
> by "tcpdump -i any" on kernel 2.4.26 with all packets arriving and 
> departing on an e1000 NIC. That is, the ordering by receive timestamp on 
> the packets is not the same as the ordering of the packets within the file.
> 
> In my precise scenario, packets of RX packets show up in the log 230 ms 
> later than they ought to based on the receive timestamp. The kernel 
> behavior (e.g., the packets that are sent by this node) seems to reflect 
> the arrival of the Rx packet at the position in the logfile, rather than 
> the arrival time according to the timestamp.
> 
> What are some of the known causes of this behavior? I'd like to know 
> what locks, etc. might be causing this processing / capture delay.

SMP or single CPU? What is the clock source being used?
If you had a CPU like dual-core AMD that doesn't sync TSC's and
that was the clock source, the timestamps could be wrong.
