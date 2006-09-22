From: Douglas Leith <doug.leith@nuim.ie>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Fri, 22 Sep 2006 20:38:07 +0100
Message-ID: <45143B9F.9080000@nuim.ie>
References: <4513F1A1.3000506@nuim.ie>
 <5640c7e00609221042w5122c37cm7db3013e21e3b5dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: end2end-interest@postel.org, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:29948 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S964812AbWIVTj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 15:39:29 -0400
Received: from [192.168.0.2] ([212.2.173.133])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M7IBW7X3CQ00UXSI@NUIM.IE>
 for netdev@vger.kernel.org; Fri, 22 Sep 2006 20:39:38 +0000 (GMT)
In-reply-to: <5640c7e00609221042w5122c37cm7db3013e21e3b5dc@mail.gmail.com>
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald wrote:
> On 9/23/06, Douglas Leith <doug.leith@nuim.ie> wrote:
>> For those interested in TCP for high-speed environments, and perhaps
>> also people interested in TCP evaluation generally, I'd like to point
>> you towards the results of a detailed experimental study which are now
>> available at:
>>
>> http://www.hamilton.ie/net/eval/ToNfinal.pdf
>>
>> This study consistently compares Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP
>> and H-TCP performance under a wide range of conditions including with
>> mixes of long and short-lived flows.  This study has now been subject to
>> peer review (to hopefully give it some legitimacy) and is due to appear
>> in the Transactions on Networking.
>>
>> The conclusions (see summary below) seem especially topical as BIC-TCP
>> is currently widely deployed as the default algorithm in Linux.
>>
>> Comments appreciated.  Our measurements are publicly available - on the
>> web or drop me a line if you'd like a copy.
>>
>> Summary:
>> In this paper we present experimental results evaluating the
>> performance of the Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP and
>> H-TCP proposals in a series of benchmark tests.
>>
>> We find that many recent proposals perform surprisingly poorly in
>> even the most simple test, namely achieving fairness between two
>> competing flows in a dumbbell topology with the same round-trip
>> times and shared bottleneck link. Specifically, both Scalable-TCP
>> and FAST TCP exhibit very substantial unfairness in this test.
>>
>> We also find that Scalable-TCP, HS-TCP and BIC-TCP induce significantly
>> greater RTT unfairness between competing flows with different round-trip
>> times.  The unfairness can be an order of magnitude greater than that
>> with standard TCP and is such that flows with longer round-trip times
>> can be completely starved of bandwidth.
>>
>> While the TCP proposals studied are all successful at improving
>> the link utilisation in a relatively static environment with
>> long-lived flows, in our tests many of the proposals exhibit poor
>> responsiveness to changing network conditions.  We observe that
>> Scalable-TCP, HS-TCP and BIC-TCP can all suffer from extremely
>> slow (>100s) convergence times following the startup of a new
>> flow. We also observe that while FAST-TCP flows typically converge
>> quickly initially, flows may later diverge again to create
>> significant and sustained unfairness.
>>
>> --Doug
>>
>> Hamilton Institute
>> www.hamilton.ie
>>
>>
>>
> Interesting reading and I am replying to netdev@vger.kernel.org as
> well. I will read in more detail later but my first questions/comments
> are:
> - have you tested CUBIC subsequently as this is meant to fix many of
> the rtt issues? This is becoming the default in 2.6.19 probably.
> - have you tested subsequently on more recent kernels than 2.6.6?
> 
> Looks like some very useful information.
> 
> Regards,
> 
> Ian
Ian,

We haven't tested cubic yet.  Inevitably there's a delay in running 
tests, getting them properly reviewed (essential for credibility I think 
when results can be controversial) etc and so there are quite a few 
proposed algorithms that are post out tests and so not covered, 
including cubic.  I think this certainly motivates further rounds of 
testing.  We have tested later kernels, but we found the results are 
much the same as with the 2.6.6 kernel used (which included sack 
processing patches etc that have now largely been incorporated into 
later kernels).

I wasn't aware of the planned move to cubic in Linux.  Can I ask the 
rationale for this ?  Cubic is, of course, closely related to HTCP 
(borrowing the HTCP idea of using elapsed time since last backoff as the 
quantity used to adjust the cwnd increase rate) which *is* tested in the 
reported study.  I'd be more than happy to run tests on cubic and I 
reckon we should do this sooner rather than later now that you have 
flagged up plans to rollout cubic.

Doug

Hamilton Institute
www.hamilton.ie
