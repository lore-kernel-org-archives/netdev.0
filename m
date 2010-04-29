From: Bijay Singh <Bijay.Singh@guavus.com>
Subject: Re: TCP MD5 issue
Date: Thu, 29 Apr 2010 01:49:24 +0000
Message-ID: <7F9EF72D-8D9E-4C36-983F-96589B6F7D02@guavus.com>
References: <F7E69C56-3340-476E-8C5B-415E4B2E8DF4@guavus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [204.232.241.167] ([204.232.241.167]:17644 "EHLO mx1.guavus.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755819Ab0D2Bt3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 21:49:29 -0400
In-Reply-To: <F7E69C56-3340-476E-8C5B-415E4B2E8DF4@guavus.com>
Content-Language: en-US
Content-ID: <16831cf8-cfde-4b09-ba11-de7f8cfbb51a>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Hi,
> 
> I have hit upon bug in the TCP MD5 implementation. The bug shows up in load conditions. I haven't  been able to exactly identify the issue, but is easily reproducible.
> 
> I run multiple instances (44 pairs) of servers and clients. All servers running on ubuntu 2.6.31 and all clients running on 2.6.26.
> 
> I observe that few messages from either end have invalid MD5 Hash signatures.
> 
> I browsed thru the code and did not find anything suspicious.
> 
> I hacked the code (2.6.26) to call the .calc_md5_hash function twice at the same point and printked the hashes from the .calc_md5_hash function. I noticed that sometimes the 1st call gives the in correct value and sometimes the 2nd call gives the in correct value, which essentially leads me the believe that the input to the fucntions are not getting modified. 
> 
> I short-circuited the crypto and called the md5 functions directly and allocated the md5 context from the stack, to remove any kind of sharing violation that may be happening. (the context otherwise is saved per cpu in the md5_sig_pool and the exection of the hash generation code is made non-preemtbale to prevent sharing voilation). btw what will happen if there is an interupt.
> 
> After this change the code is running much more smoothly, however i did manage to get 6 error in 4 hours, earlier i was seen invalid cheksum errors with secs of starting the load.
> 
> I have rerun the test and haven't observed any error since last 2 hours.
> 
> I need to fix this issue and am heavily dependent on you to provide me with some clues to proceed further. Pls. let me know if you need any more data.
> 
> Looking forward to your response.
> 
> Thanks
> BIjay

