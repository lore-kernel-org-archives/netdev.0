From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 13:17:56 -0700
Message-ID: <434ACC74.3020404@hp.com>
References: <1128672413.13948.326.camel@localhost>
	<52br20lsei.fsf@cisco.com>	<1128738350.13945.369.camel@localhost>
	<521x2tgrim.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <521x2tgrim.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>      > 2.6.12-rc5      in-kernel    1     405   <<<<<
>      > 2.6.12-rc4      in-kernel    1     470   <<<<<
> 
> I was optimistic when I saw this, because the changeover to git
> occurred with 2.6.12-rc2, so I thought I could use git bisect to track
> down exactly when the performance regression happened.
> 
> However, I haven't been able to get numbers that are stable enough to
> track this down.  I have two systems, both HP DL145s with dual Opteron
> 875s and two-port mem-free PCI Express HCAs.  I use MSI-X with the
> completion interrupt affinity set to CPU 0, and "taskset 2" to run
> netserver and netperf on CPU 1.
> 
> With default netperf parameters (just "-H otherguy") I get numbers
> between ~490 MB/sec and ~550 MB/sec for 2.6.12-rc4 and 2.6.12-rc5.
> The numbers are quite consistent between reboots, but if I reboot the
> system (even keeping the kernel identical), I see large performance
> changes.  Presumably something is happening like the cache coloring of
> some hot data structures changing semi-randomly depending on the
> timing of various initialations.

Which rev of netperf are you using, and areyou using the "confidence intervals" 
options (-i, -I)?  for a long time, the linux-unique behaviour of returning the 
overhead bytes for SO_[SND|RCV]BUF and them being 2X what one gives in 
setsockopt() gave netperf some trouble - the socket buffer would double in size 
each iteration on a confidence interval run.  Later netperf versions (late 2.3, 
and 2.4.X) have a kludge for this.

Slightly related to that, IIRC, the linux receiver code adjusts the advertised 
window as the connection goes along - how far the receive code opens the window 
may change from run to run - might that have an effect?  If there is a way to 
get the linux receiver to simply advertise the full window from the beginning 
that might help minimize the number of variables.

Are there large changes in service demand along with the large performance changes?

FWIW, on later netperfs the -T option should allow you to specify the CPU on 
which netperf and/or netserver run, although I've had some trouble reliably 
detecting the right sched_setaffinity syntax among the releases.

rick jones
