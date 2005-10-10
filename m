From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 11:23:45 -0700
Message-ID: <521x2tgrim.fsf@cisco.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
In-Reply-To: <1128738350.13945.369.camel@localhost> (Matt Leininger's
	message of "Fri, 07 Oct 2005 19:25:49 -0700")
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

     > 2.6.12-rc5      in-kernel    1     405   <<<<<
     > 2.6.12-rc4      in-kernel    1     470   <<<<<

I was optimistic when I saw this, because the changeover to git
occurred with 2.6.12-rc2, so I thought I could use git bisect to track
down exactly when the performance regression happened.

However, I haven't been able to get numbers that are stable enough to
track this down.  I have two systems, both HP DL145s with dual Opteron
875s and two-port mem-free PCI Express HCAs.  I use MSI-X with the
completion interrupt affinity set to CPU 0, and "taskset 2" to run
netserver and netperf on CPU 1.

With default netperf parameters (just "-H otherguy") I get numbers
between ~490 MB/sec and ~550 MB/sec for 2.6.12-rc4 and 2.6.12-rc5.
The numbers are quite consistent between reboots, but if I reboot the
system (even keeping the kernel identical), I see large performance
changes.  Presumably something is happening like the cache coloring of
some hot data structures changing semi-randomly depending on the
timing of various initialations.

Matt, how stable are your numbers?

 - R.
