From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats in action policer
Date: Wed, 15 Dec 2004 16:22:52 +0100
Message-ID: <20041215152252.GM8493@postel.suug.ch>
References: <20041215130128.GK8493@postel.suug.ch> <1103119774.1077.74.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103119774.1077.74.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103119774.1077.74.camel@jzny.localdomain> 2004-12-15 09:09
> 
> Hopefully this makes my point to Patrick earlier about regression
> testing? ;-> Good effort Thomas.

I generally agree with you but I also understand patrick's point. The
testsuite doesn't replace manual testing for explict changes but rather
helps to catch the easly forgotten cases.

I made some significant changes to the testsuite and I'm still adding
lots of tests. I already found a few minor bugs such as unhandled policer
results, unhandled error cases in action configuration which I will
push patches for once 2.6.10 is out.

The architecture currently looks like this:

 qdisc specific and generic tests
 foreach classful-qdisc
   classifier specific and generic tests
   foreach classifier
     action/policer/indev tests

generic tests include:
 - add,dump,delete,add,delete basic tests
 - stress tests (adding/dumping/deleting a few hundred objects)
 - statistics tests

So for example indev is tested K*I*N*M times where K is the number of
kernels available in my testing enviroment, I is the number of
iproute2 versions, N is the number of classful qdiscs and M is the
number of classifiers supporting indev.  This helps to catch bugs
specific to a certain module and can be used to check consistency
between various iproute2 modules.

/proc/conf.gz gets splitted up and is provided to the test scripts
as enviroment variables so they can easly check if the kernel is
capable of for example indev and if not check if it properly returns
an error code.

I will publish the latest testsuite as soon as I've finished writing
the most urgent tests.
