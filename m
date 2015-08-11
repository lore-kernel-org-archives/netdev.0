From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next v2] tcp: reduce cpu usage under tcp memory pressure
 when SO_SNDBUF is set
Date: Tue, 11 Aug 2015 11:03:30 -0400
Message-ID: <55CA0EC2.9030306@akamai.com>
References: <20150811143846.672A92039@prod-mail-relay10.akamai.com> <1439304576.1084.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-175.deploy.static.akamaitechnologies.com ([23.79.238.175]:16884
	"EHLO prod-mail-xrelay07.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752281AbbHKPDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 11:03:31 -0400
In-Reply-To: <1439304576.1084.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/11/2015 10:49 AM, Eric Dumazet wrote:
> On Tue, 2015-08-11 at 14:38 +0000, Jason Baron wrote:
>> From: Jason Baron <jbaron@akamai.com>
> 
>> In my testing, this brought a single threaad's cpu usage down from 100% to ~1%
>> while maintaining the same level of throughput.
>>
> 
> Hi Jason. Could you give more details on this test ?
> 
> How many flows are competing ?
> 
>

Yes, so the test case I'm using to test against is somewhat contrived.
In that I am simply allocating around 40,000 sockets that are idle to
create a 'permanent' memory pressure in the background. Then, I have
just 1 flow that sets SO_SNDBUF, which results in the: poll(), write() loop.

That said, we encountered this issue initially where we had 10,000+
flows and whenever the system would get into memory pressure, we would
see all the cpus spin at 100%.

So the testcase I wrote, was just a simplistic version for testing. But
I am going to try and test against the more realistic workload where
this issue was initially observed.

Thanks,

-Jason
