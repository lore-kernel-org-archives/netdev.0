From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 21:03:35 -0700
Message-ID: <52u0fod7jc.fsf@cisco.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost> <521x2tgrim.fsf@cisco.com>
	<1128986707.13945.424.camel@localhost> <52br1xdjtm.fsf@cisco.com>
	<1128987897.13952.441.camel@localhost> <527jcldj4n.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
In-Reply-To: <527jcldj4n.fsf@cisco.com> (Roland Dreier's message of "Mon, 10
	Oct 2005 16:53:12 -0700")
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

    Roland> I might get a chance to do it tonight... I'll post if I do.

I'm giving it a shot but I just can't reproduce this well on my
systems.  I do see a pretty big regression between 2.6.12-rc4 and
2.6.14-rc2, but 2.6.12-rc5 looks OK on my systems.

I reflashed to FW 4.7.0 (mem-ful) and built netperf 2.4.1.

With 2.6.12-rc4 I've seen runs as slow as:

    TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.145.2 (192.168.145.2) port 0 AF_INET
    Recv   Send    Send                          Utilization       Service Demand
    Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
    Size   Size    Size     Time     Throughput  local    remote   local   remote
    bytes  bytes   bytes    secs.    MBytes  /s  % S      % U      us/KB   us/KB
    
     87380  16384  16384    10.00       553.71   37.46    -1.00    2.642   -1.000

and with 2.6.12-rc5 I've seen runs as fast as:

    TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.145.2 (192.168.145.2) port 0 AF_INET
    Recv   Send    Send                          Utilization       Service Demand
    Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
    Size   Size    Size     Time     Throughput  local    remote   local   remote
    bytes  bytes   bytes    secs.    MBytes  /s  % S      % U      us/KB   us/KB
    
     87380  16384  16384    10.00       581.82   39.58    -1.00    2.657   -1.000

so not much difference there.  With 2.6.14-rc2, the best of 10 runs was:

    TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.145.2 (192.168.145.2) port 0 AF_INET
    Recv   Send    Send                          Utilization       Service Demand
    Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
    Size   Size    Size     Time     Throughput  local    remote   local   remote
    bytes  bytes   bytes    secs.    MBytes  /s  % S      % U      us/KB   us/KB
    
     87380  16384  16384    10.01       497.00   39.71    -1.00    3.121   -1.000

so we've definitely lost something there.

Time to do some more bisecting...

 - R.
