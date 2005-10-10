From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 14:22:40 -0700
Message-ID: <434ADBA0.5070103@hp.com>
References: <1128672413.13948.326.camel@localhost>
	<52br20lsei.fsf@cisco.com>	<1128738350.13945.369.camel@localhost>
	<521x2tgrim.fsf@cisco.com>	<434ACC74.3020404@hp.com>
	<52irw5f5t0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <52irw5f5t0.fsf@cisco.com>
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
>     Rick> Which rev of netperf are you using, and areyou using the
>     Rick> "confidence intervals" options (-i, -I)?  for a long time,
>     Rick> the linux-unique behaviour of returning the overhead bytes
>     Rick> for SO_[SND|RCV]BUF and them being 2X what one gives in
>     Rick> setsockopt() gave netperf some trouble - the socket buffer
>     Rick> would double in size each iteration on a confidence interval
>     Rick> run.  Later netperf versions (late 2.3, and 2.4.X) have a
>     Rick> kludge for this.
> 
> I believe it's netperf 2.2.

That's rather old.  I literally just put 2.4.1 out on ftp.cup.hp.com - probably 
better to use that if possible. Not that it will change the variability just 
that I like it when people are up-to-date on the versions :)  If nothing else, 
the 2.4.X version(s) have a much improved (hopefully) manual in doc/


[If you are really maschochistic, the very first release of netperf 4.0.0 source 
has happened. I can make no guarantees as to its actually working at the moment 
though :) Netperf4 is going to be the stream for the multiple-connection, 
multiple system tests rather than the single-connection nature of netperf2]

> I'm not using any confidence interval stuff.  However, the variation
> is not between single runs of netperf -- if I do 5 runs of netperf in
> a row, I get roughly the same number from each run.  For example, I
> might see something like
> 
>     TCP STREAM TEST to 192.168.145.2 : histogram
>     Recv   Send    Send
>     Socket Socket  Message  Elapsed
>     Size   Size    Size     Time     Throughput
>     bytes  bytes   bytes    secs.    10^6bits/sec
>     
>      87380  16384  16384    10.00    3869.82
>     
> and then
> 
>     TCP STREAM TEST to 192.168.145.2 : histogram
>     Recv   Send    Send
>     Socket Socket  Message  Elapsed
>     Size   Size    Size     Time     Throughput
>     bytes  bytes   bytes    secs.    10^6bits/sec
>     
>      87380  16384  16384    10.00    3862.41
> 
> for two successive runs.  However, if I reboot the system into the
> same kernel (ie everything set up exactly the same), the same
> invocation of netperf might give
> 
>     TCP STREAM TEST to 192.168.145.2 : histogram
>     Recv   Send    Send
>     Socket Socket  Message  Elapsed
>     Size   Size    Size     Time     Throughput
>     bytes  bytes   bytes    secs.    10^6bits/sec
>     
>      87380  16384  16384    10.00    4389.20
> 
>     Rick> Are there large changes in service demand along with the
>     Rick> large performance changes?
> 
> Not sure.  How do I have netperf report service demand?

Ask for CPU utilization with -c (local) and -C (remote).  The /proc/stat stuff 
used by Linux does not need calibration (IIRC) so you don't have to worry about 
that.

If cache effects are involved, you can make netperf "harder" or "easier" on the 
caches by altering the size of the send and/or recv buffer rings.  By default 
they are one more than the socket buffer size divided by the send size, but you 
can make them larger or smaller with the -W option.

These days I use a 128K socket buffer and 32K send for the "canonical" (although 
  not default :) netperf TCP_STREAM test:

netperf -H remote -c -C -- -s 128K -S 128K -m 32K

In netperf-speak K == 1024, k == 1000, M == 2^20, m == 10^6, G == 2^40, g == 10^9...
rick jones
