From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] vhost: Make it more scalable by creating a vhost
	thread per device.
Date: Fri, 09 Apr 2010 08:39:40 -0700
Message-ID: <1270827580.25555.13.camel@w-sridhar.beaverton.ibm.com>
References: <1270229480.13897.8.camel@w-sridhar.beaverton.ibm.com>
	 <1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>
	 <1270771542.31186.397.camel@w-sridhar.beaverton.ibm.com>
	 <4BBE716B.7050904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Tom Lendacky <toml@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4BBE716B.7050904@hp.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-04-08 at 17:14 -0700, Rick Jones wrote:
> > Here are the results with netperf TCP_STREAM 64K guest to host on a
> > 8-cpu Nehalem system.
> 
> I presume you mean 8 core Nehalem-EP, or did you mean 8 processor Nehalem-EX?

Yes. It is a 2 socket quad-core Nehalem. so i guess it is a 8 core
Nehalem-EP.
> 
> Don't get me wrong, I *like* the netperf 64K TCP_STREAM test, I lik it a lot!-) 
> but I find it incomplete and also like to run things like single-instance TCP_RR 
> and multiple-instance, multiple "transaction" (./configure --enable-burst) 
> TCP_RR tests, particularly when concerned with "scaling" issues.

Can we run multiple instance and multiple transaction tests with a
single netperf commandline?

Is there any easy way to get consolidated throughput when a netserver on
the host is servicing netperf clients from multiple guests?

Thanks
Sridhar

> 
> happy benchmarking,
> 
> rick jones
> 
> > It shows cumulative bandwidth in Mbps and host 
> > CPU utilization.
> > 
> > Current default single vhost thread
> > -----------------------------------
> > 1 guest:  12500  37%    
> > 2 guests: 12800  46%
> > 3 guests: 12600  47%
> > 4 guests: 12200  47%
> > 5 guests: 12000  47%
> > 6 guests: 11700  47%
> > 7 guests: 11340  47%
> > 8 guests: 11200  48%
> > 
> > vhost thread per cpu
> > --------------------
> > 1 guest:   4900 25%
> > 2 guests: 10800 49%
> > 3 guests: 17100 67%
> > 4 guests: 20400 84%
> > 5 guests: 21000 90%
> > 6 guests: 22500 92%
> > 7 guests: 23500 96%
> > 8 guests: 24500 99%
> > 
> > vhost thread per guest interface
> > --------------------------------
> > 1 guest:  12500 37%
> > 2 guests: 21000 72%
> > 3 guests: 21600 79%
> > 4 guests: 21600 85%
> > 5 guests: 22500 89%
> > 6 guests: 22800 94%
> > 7 guests: 24500 98%
> > 8 guests: 26400 99%
> > 
> > Thanks
> > Sridhar
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

