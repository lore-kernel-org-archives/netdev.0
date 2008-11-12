From: Brian Haley <brian.haley@hp.com>
Subject: Re: Fwd: [Bug 470774] New: [RFC1981-PMTU]Multicast Destination -
 One	Router test failed
Date: Wed, 12 Nov 2008 10:12:03 -0500
Message-ID: <491AF243.9040904@hp.com>
References: <20081111174232.GA32434@redhat.com> <4919E1F3.1080101@hp.com> <491A7571.4020905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dave jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: wang_jiabo <jiabwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:11769 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbYKLPMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 10:12:05 -0500
In-Reply-To: <491A7571.4020905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> So which TAHI test was this?  Have they tracked down a commit that 
>> caused this to break?
> I use TAHI 4-0-3 RFC1981, if you can access my website , please see 
> http://10.66.65.20/self_test/ipv6-core/Self_Test_4-0-3_F10/

That looks like an internal link.  Either way, I'm guessing this was 
test 13 (Checking For Increase in PMTU), which passed for RHEL 5.3 
recently I think.

>>> Version-Release number of selected component (if applicable):
>>> 2.6.27-0.352.rc7.git1.fc10.i686
>>
>> Hmmm, I would take a look at this commit:
>>
>> commit b5c15fc004ac83b7ad280acbe0fd4bbed7e2c8d4
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Thu Feb 14 23:49:37 2008 -0800
>>
>>     [IPV6]: Fix reversed local_df test in ip6_fragment
>>
>>     I managed to reverse the local_df test when forward-porting this
>>     patch so it actually makes things worse by never fragmenting at
>>     all.
>>
>>     Thanks to David Stevens for testing and reporting this bug.
>>
>>     Bill Fink pointed out that the local_df setting is also the wrong
>>     way around.

So can you verify your kernel has this fix?  Or can you run a later 
kernel and see if it's fixed?

> I check using the command, get the following info:
>  #cat /proc/net/dev_snmp6/eth0|grep -i frag
>    Ipv6FragOKs           0
>    Ipv6FragFails           0
>    Ip6FragCreates        0

You'll actually want to look at eth1, which is where the pings are going 
out, I was just giving that as an example.

-Brian
