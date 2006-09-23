From: Douglas Leith <doug.leith@nuim.ie>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Sat, 23 Sep 2006 07:34:56 +0100
Message-ID: <4514D590.9010201@nuim.ie>
References: <001b01c6deb8$c0375bc0$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: floyd@ICSI.Berkeley.EDU, netdev@vger.kernel.org,
	end2end-interest@postel.org, lisongxu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:42744 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S1751137AbWIWGgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 02:36:18 -0400
Received: from [192.168.0.2] ([212.2.173.133])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M7IYUJHQU600QB7H@NUIM.IE>
 for netdev@vger.kernel.org; Sat, 23 Sep 2006 07:36:27 +0000 (GMT)
In-reply-to: <001b01c6deb8$c0375bc0$4a580e98@ncsu2cc0c3fa00>
To: Injong Rhee <rhee@eos.ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I suggest you take a closer look Injong - there is a whole page of data 
from tests covering a wide range of levels of background traffic.  These 
results are all new, and significantly strengthen the conclusions I 
think, as is the expanded explanatory discussion of the observed 
behaviour of the various algorithms (the result of a fair bit of 
detective work of course).  Your claim that "Your report mostly ignores 
the effect of background traffic" is simply not true.

I can't really comment on your own tests without more information, 
although I can say that we went to a good bit of trouble to make sure 
our results were consistent and reproducible - in fact all our reported 
results are from at least five, and usually more, runs of each test.  We 
were also careful to control for differences in kernel implementation so 
that we compare congestion control algorithms rather than other aspects 
of the network stack implementation.  All of this is documented in the 
paper.  The kernel we used is available on the web.  Our measurements 
are also publicly available - the best way forward might be to pick one 
or two tests and compare results of them in detail with a view to 
diagnosing the source of any differences.

General comments such as "our experience tells that the RTT variations 
of mid size flows play a very important role in creating significant 
dynamics in testing environments" are not too helpful.  What do you mean 
by a "mid-sized flow" ?  What do you mean by "significant dynamics" ? 
What do you mean by "important role" - is this quantified ?  Best to 
stick to science rather than grandstanding.  This is especially true 
when dealing with a sensitive subject such as the evaluation of 
competing algorithms.

Re FAST, we have of course discussed our results with the Caltech folks. 
  As stated in the paper, some of the observed behaviour seems to be 
associated with the alpha tuning algorithm.  Other behaviour seems to be 
associated with packet burst effects that have also been reported 
independently by the Caltech folks.  Similar results to ours have since 
been observed by other groups I believe.  Perhaps differences between 
our results point to some issue in your testbed setup.

Doug

Injong Rhee wrote:
> 
> 
> This is a resend with fixed web links. The links were broken in my 
> previous email -- sorry about multiple transmissions.
> 
> --------------------------------------------------------------------------------- 
> 
> 
> Hi Doug,
> 
> Thanks for sharing your paper. Also congratulations to the acceptance of 
> your journal paper to TONs. But I am wondering what's new in this paper. 
> At first glance, I did not find many new things that are different from 
> your previously publicized reports. How much is this different from the 
> ones you put out in this mail list a year or two ago and also the one 
> publicized in PFLDnet February this year 
> http://www.hpcc.jp/pfldnet2006/? In that same workshop, we also 
> presented our experimental results that shows significant discrepancy 
> from yours but i am not sure why you forgot to reference our 
> experimental work presented in that same PFLDnet. Here is a link to a 
> more detailed version of that report accepted to COMNET 
> http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf
> 
> The main point of contention [that we talked about in that PFLDnet 
> workshop] is the presence of background traffic and the method to add 
> them. Your report mostly ignores the effect of background traffic. Some 
> texts in this paper state that you added some web traffic (10%), but the 
> paper shows only the results from NO background traffic scenarios. But 
> our results differ from yours in many aspects. Below are the links to 
> our results (the links to them have been available in our BIC web site 
> for a long time and also mentioned in our PFLDnet paper; this result is 
> with the patch that corrects HTCP bugs).
> 
> [Convergence and intra protocol fairness]
> 
> without background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/intra_protocol.htm 
> 
> 
> with background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/intra_protocol.htm 
> 
> 
> [RTT fairness]:
> 
> w/o background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/rtt_fairness.htm 
> 
> 
> with background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/rtt_fairness.htm
> 
> [TCP friendliness]
> 
> without background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friendliness/tcp_friendliness.htm 
> 
> 
> with background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/tcp_friendliness.htm 
> 
> 
> After our discussion in that PFLDnet, I puzzled why we get different 
> results. My guess is that the main difference between your experiment 
> and ours is the inclusion of mid-sized flows with various RTTs -- our 
> experience tells that the RTT variations of mid size flows play a very 
> important role in creating significant dynamics in testing environments. 
> The same point about the importance of mid size flows with RTT 
> variations has been raised in several occasions by Sally Floyd as well, 
> including in this year's E2E research group meeting. You can find some 
> reference to the importance of RTT variations in her paper too [ 
> http://www.icir.org/models/hotnetsFinal.pdf]. Just having web-traffic 
> (all with the same RTTs) does not create a realistic environment as it 
> does not do anything about RTTs and also flow sizes tend to be highly 
> skewed with the Pareto distribution-- but I don't know exactly how you 
> create your testing environment with web-traffic -- I can only guess 
> from the description you have about the web traffic in your paper.
> 
> Another puzzle in this difference seems that even under no background 
> traffic, we also get different results from yours..hmm...especially with 
> FAST because under no background traffic, FAST seems to work fairly well 
> with good RTT fairness in our experiment. But your results show FAST has 
> huge RTT-unfairness. That is very strange. Is that because we have 
> different bandwidth and buffer sizes in the setup? I think we need to 
> compare our notes more. Also in the journal paper of FAST experimental 
> results [ 
> http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf ], 
> FAST seems to work very well under no background traffic. We will verify 
> our results again in the exact same environment as you have in your 
> report, to make sure we can reproduce your results....but here are some 
> samples of our results for FAST.
> 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200--2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6-1000-10-1200-64000-150--1/ 
> 
> 
> In this experiment, FAST flows are just perfect. Also the same result is 
> confirmed inthe FAST journal paper [ 
> http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf -- 
> please look at Section IV.B and C. But your results show really bad RTT 
> fairness.]
> 
> Best regards,
> 
> Injong
> 
> ---
> 
> Injong Rhee
> 
> NCSU
> 
> On Sep 22, 2006, at 10:22 AM, Douglas Leith wrote:
> 
> For those interested in TCP for high-speed environments, and perhaps 
> also people interested in TCP evaluation generally, I'd like to point 
> you towards the results of a detailed experimental study which are now 
> available at:
> 
>  
> 
> http://www.hamilton.ie/net/eval/ToNfinal.pdf 
> <http://www.hamilton.ie/net/eval/ToNfinal.pdf>
> 
>  
> 
> This study consistently compares Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP 
> and H-TCP performance under a wide range of conditions including with 
> mixes of long and short-lived flows. This study has now been subject to 
> peer review (to hopefully give it some legitimacy) and is due to appear 
> in the Transactions on Networking.
> 
>  
> 
> The conclusions (see summary below) seem especially topical as BIC-TCP 
> is currently widely deployed as the default algorithm in Linux.
> 
>  
> 
> Comments appreciated. Our measurements are publicly available - on the 
> web or drop me a line if you'd like a copy.
> 
>  
> 
> Summary:
> 
> In this paper we present experimental results evaluating the
> 
> performance of the Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP and
> 
> H-TCP proposals in a series of benchmark tests.
> 
>  
> 
> We find that many recent proposals perform surprisingly poorly in
> 
> even the most simple test, namely achieving fairness between two
> 
> competing flows in a dumbbell topology with the same round-trip
> 
> times and shared bottleneck link. Specifically, both Scalable-TCP
> 
> and FAST TCP exhibit very substantial unfairness in this test.
> 
>  
> 
> We also find that Scalable-TCP, HS-TCP and BIC-TCP induce significantly 
> greater RTT unfairness between competing flows with different round-trip 
> times. The unfairness can be an order of magnitude greater than that 
> with standard TCP and is such that flows with longer round-trip times
> 
> can be completely starved of bandwidth.
> 
>  
> 
> While the TCP proposals studied are all successful at improving
> 
> the link utilisation in a relatively static environment with
> 
> long-lived flows, in our tests many of the proposals exhibit poor
> 
> responsiveness to changing network conditions. We observe that
> 
> Scalable-TCP, HS-TCP and BIC-TCP can all suffer from extremely
> 
> slow (>100s) convergence times following the startup of a new
> 
> flow. We also observe that while FAST-TCP flows typically converge
> 
> quickly initially, flows may later diverge again to create
> 
> significant and sustained unfairness.
> 
>  
> 
> --Doug
> 
>  
> 
> Hamilton Institute
> 
> www.hamilton.ie <http://www.hamilton.ie/>
> 

