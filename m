From: Alan Shieh <ashieh@cs.cornell.edu>
Subject: Re: Packet reordering in pcap capture file
Date: Mon, 07 Aug 2006 03:51:33 -0400
Message-ID: <44D6F105.7060600@cs.cornell.edu>
References: <44D448A6.6020803@cs.cornell.edu> <20060805092154.040e57e1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchfe1.cs.cornell.edu ([128.84.97.27]:11589 "EHLO
	exchfe1.cs.cornell.edu") by vger.kernel.org with ESMTP
	id S1751132AbWHGHta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 03:49:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060805092154.040e57e1@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Sat, 05 Aug 2006 03:28:38 -0400
> Alan Shieh <ashieh@cs.cornell.edu> wrote:
> 
> 
>>Hi everyone,
>>
>>I sometimes see packets stored out of order in pcap files that generated 
>>by "tcpdump -i any" on kernel 2.4.26 with all packets arriving and 
>>departing on an e1000 NIC. That is, the ordering by receive timestamp on 
>>the packets is not the same as the ordering of the packets within the file.
>>
>>In my precise scenario, packets of RX packets show up in the log 230 ms 
>>later than they ought to based on the receive timestamp. The kernel 
>>behavior (e.g., the packets that are sent by this node) seems to reflect 
>>the arrival of the Rx packet at the position in the logfile, rather than 
>>the arrival time according to the timestamp.
>>
>>What are some of the known causes of this behavior? I'd like to know 
>>what locks, etc. might be causing this processing / capture delay.
> 
> 
> SMP or single CPU? What is the clock source being used?
> If you had a CPU like dual-core AMD that doesn't sync TSC's and
> that was the clock source, the timestamps could be wrong.

Single CPU, using TSC. The behavior of the system is as if the RTT is 
230ms, so I think a queue is building up somewhere within the kernel. I 
am trying to narrow down the possible ways my experimental code could 
have caused such a queue backlog. I've tried setting netdev->quota in 
the e1000 module to a much larger value, thus forcing the backlog to be 
processed faster, but that does not help.

Alan
