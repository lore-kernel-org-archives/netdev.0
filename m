From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 11:11:30 +0200
Message-ID: <20090429091130.GA27857@elte.hu>
References: <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com> <49F77108.7060509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:35457 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbZD2JMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 05:12:30 -0400
Content-Disposition: inline
In-Reply-To: <49F77108.7060509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> On uddpping, I had prior to the patch about 49000 wakeups per 
> second, and after patch about 26000 wakeups per second (matches 
> number of incoming udp messages per second)

very nice. It might not show up as a real performance difference if 
the CPUs are not fully saturated during the test - but it could show 
up as a decrease in CPU utilization.

Also, if you run the test via 'perf stat -a ./test.sh' you should 
see a reduction in instructions executed:

aldebaran:~/linux/linux> perf stat -a sleep 1

 Performance counter stats for 'sleep':

   16128.045994  task clock ticks     (msecs)
          12876  context switches     (events)
            219  CPU migrations       (events)
         186144  pagefaults           (events)
    20911802763  CPU cycles           (events)
    19309416815  instructions         (events)
      199608554  cache references     (events)
       19990754  cache misses         (events)

 Wall-clock time elapsed:  1008.882282 msecs

With -a it's measured system-wide, from start of test to end of test 
- the results will be a lot more stable (and relevant) statistically 
than wall-clock time or CPU usage measurements. (both of which are 
rather imprecise in general)

	Ingo
