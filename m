From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: route cache DoS testing and softirqs
Date: Thu, 1 Apr 2004 00:36:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16491.18384.536778.338660@robur.slu.se>
References: <20040329222926.GF3808@dualathlon.random>
	<200403302005.AAA00466@yakov.inr.ac.ru>
	<20040330211450.GI3808@dualathlon.random>
	<20040330133000.098761e2.davem@redhat.com>
	<20040330213742.GL3808@dualathlon.random>
	<20040331171023.GA4543@in.ibm.com>
	<16491.4593.718724.277551@robur.slu.se>
	<20040331203750.GB4543@in.ibm.com>
	<20040331212817.GQ2143@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dipankar Sarma <dipankar@in.ibm.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20040331212817.GQ2143@dualathlon.random>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andrea Arcangeli writes:

 > Maybe the problem is simply that NAPI should be tuned more aggressively,
 > it may have to poll for a longer time before giving up.

 It cannot poll much more... 20 Million packets were injected in total
 there were 250 RX irq's. Most from my ssh sessions. There are some TX 
 interrupts... it's another story

 Packet flooding is just our way to generate load and kernel locking must 
 work with and without irq's. As far as I understand the real problem is 
 when do_softirq is run from irqexit etc.

 Some thoughts...

 If we tag the different do_softirq sources (look in my testpatch) we can 
 control the softirqs better. For example; do_softirq's from irqexit etc 
 could be given low a "max_restart" this to move processing to ksoftird 
 maybe even dynamic.

 Cheers.
						--ro
