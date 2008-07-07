From: Rick Jones <rick.jones2@hp.com>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 15:50:21 -0700
Message-ID: <48729DAD.8010400@hp.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Jim Rees <rees@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:36427 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177AbYGGWuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 18:50:25 -0400
In-Reply-To: <48728B09.1050801@citi.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olga Kornievskaia wrote:
> Stephen Hemminger wrote:
>> It would be better if NFSD stayed out of doign setsockopt and just
>> let the sender/receiver autotuning work?
>>   
> 
> Auto-tuning would be guided by the sysctl values that are set for all 
> applications. I could be wrong but what I see is that unless an 
> application does a setsockopt(), its window is bound by the default 
> sysctl value. If it is true, than it is not acceptable. It means that in 
> order for NFSD to achieve a large enough window it needs to modify TCP's 
> sysctl value which will effect all other applications.

My experience thusfar is that the sysctl defaults will allow an 
autotuned TCP receive window far larger than it will allow with a direct 
setsockopt() call.

I'm still a triffle puzzled/concerned/confused by the extent to which 
autotuning will allow the receive window to grow, again based on some 
netperf experience thusfar, and patient explanations provided here and 
elsewhere, it seems as though autotuning will let things get to 2x what 
it thinks the sender's cwnd happens to be.  So far under netperf testing 
that seems to be the case, and 99 times out of ten my netperf tests will 
have the window grow to the max.

rick jones
