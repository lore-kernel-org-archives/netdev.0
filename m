From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] vhost: Make it more scalable by creating a vhost	thread
 per device.
Date: Fri, 09 Apr 2010 10:13:08 -0700
Message-ID: <4BBF6024.6060809@hp.com>
References: <1270229480.13897.8.camel@w-sridhar.beaverton.ibm.com>	<1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>	<1270771542.31186.397.camel@w-sridhar.beaverton.ibm.com>	<4BBE716B.7050904@hp.com> <1270827580.25555.13.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Tom Lendacky <toml@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1270827580.25555.13.camel@w-sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> On Thu, 2010-04-08 at 17:14 -0700, Rick Jones wrote:
> 
>>>Here are the results with netperf TCP_STREAM 64K guest to host on a
>>>8-cpu Nehalem system.
>>
>>I presume you mean 8 core Nehalem-EP, or did you mean 8 processor Nehalem-EX?
> 
> 
> Yes. It is a 2 socket quad-core Nehalem. so i guess it is a 8 core
> Nehalem-EP.
> 
>>Don't get me wrong, I *like* the netperf 64K TCP_STREAM test, I lik it a lot!-) 
>>but I find it incomplete and also like to run things like single-instance TCP_RR 
>>and multiple-instance, multiple "transaction" (./configure --enable-burst) 
>>TCP_RR tests, particularly when concerned with "scaling" issues.
> 
> 
> Can we run multiple instance and multiple transaction tests with a
> single netperf commandline?

Do you count a shell for loop as a single command line?

> Is there any easy way to get consolidated throughput when a netserver on
> the host is servicing netperf clients from multiple guests?

I tend to use a script such as:

ftp://ftp.netperf.org/netperf/misc/runemomniagg2.sh

which presumes that netperf/netserver have been built with:

./configure --enable-omni --enable-burst ...

and uses the CSV output format of the omni tests.  When I want sums I then turn 
to a spreadsheet, or I suppose I could turn to awk etc.

The TCP_RR test can be flipped around request size for response size etc, so 
when I have a single sustem under test, I initiate the netperf commands on it, 
targetting netservers on the clients.  If I want inbound bulk throughput I use 
the TCP_MAERTS test rather than the TCP_STREAM test.

happy benchmarking,

rick jones
