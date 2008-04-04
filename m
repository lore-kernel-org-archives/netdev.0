From: Wenji Wu <wenji@fnal.gov>
Subject: RE: A Linux TCP SACK Question
Date: Fri, 04 Apr 2008 12:49:52 -0500
Message-ID: <000001c8967c$496efa20$c95ee183@D2GT6T71>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: 'John Heffner' <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:47768 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbYDDRur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 13:50:47 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYT00HO5AMWEG@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Fri, 04 Apr 2008 12:50:00 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040412500022784 for
 <netdev@vger.kernel.org>; Fri, 04 Apr 2008 12:50:00 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYT00J01AQLGU@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Fri, 04 Apr 2008 12:50:00 -0500 (CDT)
In-reply-to: <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, John,

Thanks,

I just sat with Richard Clarson and repeat the phenomenon.

The experiment works as:

      Sender --- Router --- Receiver

Iperf is sending from the sender to the receiver. In between there is an
emulated router which runs netem. The emulated router has two interfaces,
both with netem configured.  One interface emulates the forward path and the
other for the reverse path. Both netem interfaces are configured with 1.5ms
delay and 0.15ms variance. No packet drops. Every system runs Linux 2.6.24.

When sack is on, the throughput is around 180Mbps
When sack is off, the throughput is around 260Mbps

I am sure it is not due to the computational overhead of the processing SACK
block. All of these systems are multi-core platforms, with 2G+ CPU. I run
TOP to verify, CPUs are idle most of time.

I was thinking that if the reordered ACKs/SACKs cause confusion in the
sender, and sender will unnecessarily reduce either the CWND or the
TCP_REORDERING threshold. I might need to take a serious look at the SACK
implementation. 

I will send out the tcpdump files soon,

Thanks,

wenji



-----Original Message-----
From: John Heffner [mailto:johnwheffner@gmail.com] 
Sent: Friday, April 04, 2008 11:28 AM
To: Wenji Wu
Cc: netdev@vger.kernel.org
Subject: Re: A Linux TCP SACK Question

Unless you're sending very fast, where the computational overhead of
processing SACK blocks is slowing you down, this is not expected
behavior.  Do you have more detail?  What is the window size, and how
much reordering?

Full binary tcpdumps are very useful in diagnosing this type of problem.

  -John


On Thu, Apr 3, 2008 at 9:54 PM, Wenji Wu <wenji@fnal.gov> wrote:
> Hi, Could any body help me out with Linux TCP SACK? Thanks in advance.
>
>  I run iperf to send traffic from sender to receiver. and add packet
reordering in both forward and reverse directions. I found when I turn off
the SACK/DSACK option, the throughput is better than with the SACK/DSACK on?
How could it happen in this way? did anybody encounter this phenomenon
before?
>
>
>  thanks,
>
>  wenji
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


