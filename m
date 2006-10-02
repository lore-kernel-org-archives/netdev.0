From: Douglas Leith <doug.leith@nuim.ie>
Subject: Re: cubic tcp behaviour
Date: Mon, 02 Oct 2006 22:43:19 +0100
Message-ID: <452187F7.5010106@nuim.ie>
References: <mailman.1.1159470000.5558.end2end-interest@postel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:6126 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S965424AbWJBVpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 17:45:02 -0400
Received: from [192.168.0.2] ([212.2.171.230])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M7WF7COSUI00XBNA@NUIM.IE>
 for netdev@vger.kernel.org; Mon, 02 Oct 2006 22:45:12 +0000 (GMT)
In-reply-to: <mailman.1.1159470000.5558.end2end-interest@postel.org>
To: end2end-interest@postel.org, Injong Rhee <rhee@eos.ncsu.edu>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for posting your measurements on the web Injong.

Without getting into the merits or otherwise of the coefficient of 
variation as a measure of anything users might care about, the 
individual time history plots of throughput and cwnd look interesting.

I wonder if I could flag up some curious behaviour that seems evident in 
the measurements for the cubic algorithm.  In very many of the 
individual time history plots it looks as if there are sustained periods 
(extending to 100s of seconds) of substantial unfairness between 
competing cubic flows with the same round-trip time.  See for example:

http://netsrv.csc.ncsu.edu/highspeed/convex-ordering/FullSet_old/RTTFAIR/1MB_4HS_0FLF_2RLF_SLF_320MS/600--CUBIC-CUBIC-SIMPLE--400-3-667--1000-155-0-0-1-1-5-500--200000-0.6-1000-10-600-64000-150--24/
http://netsrv.csc.ncsu.edu/highspeed/convex-ordering/FullSet_old/RTTFAIR/1MB_4HS_0FLF_2RLF_SLF_320MS/600--CUBIC-CUBIC-SIMPLE--400-3-667--1000-155-0-0-1-1-5-500--200000-0.6-1000-10-600-64000-150--17/

Can you comment on this behaviour ?  Perhaps I am misinterpreting the data.

I think its probably worth pointing out that in all the tests it looks 
as if the cubic flows are all started at much the same time - is this 
correct ?  If so, the tests do not really probe the responsiveness of 
cubic and it might well be useful to perform tests where the flows have 
significantly different start times - it was this sort of experiment (by 
ourselves a couple of years ago now - blowing my own trumpet, I know, 
but what the heck :-)) that initially highlighted the convergence issues 
with scalable-tcp, and the slow convergence of high-speed tcp and 
bic-tcp.  Slow convergence translates into possible sustained 
unfairness, for example, against new flows starting up.

Doug

Hamilton Institute
www.hamilton.ie



end2end-interest-request@postel.org wrote:
> Send end2end-interest mailing list submissions to
> 	end2end-interest@postel.org
> 
> To subscribe or unsubscribe via the World Wide Web, visit
> 	http://mailman.postel.org/mailman/listinfo/end2end-interest
> or, via email, send a message with subject or body 'help' to
> 	end2end-interest-request@postel.org
> 
> You can reach the person managing the list at
> 	end2end-interest-owner@postel.org
> 
> When replying, please edit your Subject line so it is more specific
> than "Re: Contents of end2end-interest digest..."
> 
> 
> Today's Topics:
> 
>    1. Stability of various TCP protocols [CUBIC, BIC, HTCP, HSTCP,
>       STCP] (Injong Rhee)
>    2. Re: performance of BIC-TCP, High-Speed-TCP, H-TCP etc
>       (Injong Rhee)
> 
> 
> ----------------------------------------------------------------------
> 
> Message: 1
> Date: Thu, 28 Sep 2006 12:58:02 -0400
> From: "Injong Rhee" <rhee@eos.ncsu.edu>
> Subject: [e2e] Stability of various TCP protocols [CUBIC, BIC, HTCP,
> 	HSTCP,	STCP]
> To: <end2end-interest@postel.org>
> Cc: netdev@vger.kernel.org
> Message-ID: <00d301c6e31f$4304fed0$4a580e98@ncsu2cc0c3fa00>
> Content-Type: text/plain; charset="ks_c_5601-1987"
> 
> Hi,
> I'd like to report on a measurement study regarding the stability of various TCP variant protocols. Although we can find quite a bit of work on fairness and convergence of protocols (including some theoretical studies on the topic as well), there is relatively little work on measuring the stability of protocols and its impact on protocol performance and overall health of the networks (e.g., the overall queue fluctions and link utilization). We have measured the degree of rate oscillation and fluctuation of protocols to have some understanding of protocol stability. 
> We would like to share our results with you to get some feedback from the community. 
> 
> We have some theoretical results and also experimental results. Here is the link to the experimental results. You can find links to all of our experimental data that include results from several hundred experiments.
> 
> http://netsrv.csc.ncsu.edu/convex-ordering/
> 
> If you need our report on theoretical results,  we can e-mail you the report.
> Injong Rhee
> -------------- next part --------------
> An HTML attachment was scrubbed...
> URL: http://mailman.postel.org/pipermail/end2end-interest/attachments/20060928/c42cf65c/attachment-0001.html
> 
> ------------------------------
> 
> Message: 2
> Date: Thu, 28 Sep 2006 12:33:32 -0400
> From: "Injong Rhee" <rhee@eos.ncsu.edu>
> Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
> To: <l.andrew@ieee.org>, <rhee@ncsu.edu>
> Cc: netdev@vger.kernel.org, Douglas Leith <doug.leith@nuim.ie>,
> 	lisongxu@gmail.com, floyd@icsi.berkeley.edu,
> 	end2end-interest@postel.org
> Message-ID: <00c401c6e31b$d75c9970$4a580e98@ncsu2cc0c3fa00>
> Content-Type: text/plain; format=flowed; charset="ISO-8859-1";
> 	reply-type=response
> 
> Sure. I don't mind doing this test. I am currently working with Doug Leith 
> to get to the bottom of this difference. So when we get to the PFLDnet, we 
> should have some more findings on this. But I am up for this challenge.
> 
> ----- Original Message ----- 
> From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
> To: <rhee@ncsu.edu>
> Cc: "Douglas Leith" <doug.leith@nuim.ie>; <netdev@vger.kernel.org>; 
> <floyd@icsi.berkeley.edu>; <lisongxu@gmail.com>; "Injong Rhee" 
> <rhee@eos.ncsu.edu>; <end2end-interest@postel.org>
> Sent: Wednesday, September 27, 2006 7:20 PM
> Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
> 
> 
>> Greetings all,
>>
>> On 23/09/06, rhee@ncsu.edu <rhee@ncsu.edu> wrote:
>>> Just i was pondering why we got different results and try to see if we 
>>> can
>>> come to some understanding on this different results we got. Who knows we
>>> together might run into some fundamental research issues regarding
>>> testing.
>> Since many interested parties will be around LA for PFLDnet, how about
>> getting together after that (Friday 9 Feb) to re-run some of the
>> disputed tests on one set of hardware, with everyone present to debate
>> the results?
>>
>> You're all welcome to come to Caltech to do the testing.  We can
>> provide a few servers, dummynets and Gigabit switches.  Everyone is
>> welcome to bring their scripts, and any other hardware they need.
>>
>> If there is interest, we could also have things like a round-table
>> discussion of the benefits of testing with different file-length
>> distributions (like long lived flows to understand what is happening
>> vs a range of flows to test suitability for deployment), and the
>> benefits of repeating other people's tests vs testing in as many
>> scenarios as possible.
>>
>> Who is interested in coming?
>>
>> Cheers,
>> Lachlan
>>
>> -- 
>> Lachlan Andrew  Dept of Computer Science, Caltech
>> 1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
>> Phone: +1 (626) 395-8820    Fax: +1 (626) 568-3603
>>
> 
> 
> 
> ------------------------------
> 
> _______________________________________________
> end2end-interest mailing list
> end2end-interest@postel.org
> http://mailman.postel.org/mailman/listinfo/end2end-interest
> 
> 
> End of end2end-interest Digest, Vol 31, Issue 21
> ************************************************

