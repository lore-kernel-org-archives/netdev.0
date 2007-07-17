From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters -	Take #2
Date: Tue, 17 Jul 2007 06:22:03 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF58304330045@orsmsx412.amr.corp.intel.com>
References: <4693CEAD.5050900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <arjan@linux.intel.com>,
	<akpm@linux-foundation.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hch@infradead.org>,
	<shemminger@linux-foundation.org>, <nhorman@tuxdriver.com>,
	<inaky@linux.intel.com>, <mb@bu3sch.de>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9177 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbXGQNWK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 09:22:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4693CEAD.5050900@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/10/07, Jeff Garzik <jeff@garzik.org> wrote:
    Veeraiyan, Ayyappan wrote:
    > On 7/10/07, Jeff Garzik <jeff@garzik.org> wrote:
    >> Ayyappan.Veeraiyan@intel.com wrote:
    >>

    > I will post the performance numbers later today..

Sorry for not responding earlier. We faced couple of issues like setup,
and false alarms..

Anyway here are the numbers..

Recv	Send	Send				Utilization	Service
Demand		
SocketSocketMessageElapsed		Send	Recv	Send	Recv	
Size	Size	Size	Time Throughput	local	remotelocal	remote	
Bytes	Bytes	Bytes	sec  10^6bits/s	% s	% s	us/KB	us/KB
	
87380	65536	128	60	2261.34	13.82	4.25	4.006	1.233
128
87380	65536	256	60	3332.51	14.19	5.67	2.79	1.115
256
87380	65536	512	60.01	4262.24	14.38	6.9	2.21	1.062
512
87380	65536	1024	60	4659.18	14.4	7.39	2.026	1.039
1024
87380	65536	2048	60.01	6177.87	14.36	14.99	1.524	1.59
2048
87380	65536	4096	60.01	9410.29	11.58	14.6	0.807	1.017
4096
87380	65536	8192	60.01	9324.62	11.13	14.33	0.782	1.007
8192
87380	65536	16384	60.01	9371.35	11.07	14.28	0.774	0.999
16384
87380	65536	32768	60.02	9385.81	10.83	14.27	0.756	0.997
32768
87380	65536	65536	60.01	9363.5	10.73	14.26	0.751	0.998
65536

TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to n0417
(10.0.4.17) port 0 AF_INET : cpu bind

Recv   Send    Send                      Utilization      Service Demand
Socket Socket  Message  Elapsed           Send    Recv    Send    Recv
Size   Size    Size     Time   Throughput local  remote   local   remote
bytes  bytes   bytes    secs.  10^6bits/s % S    % S      us/KB   us/KB

87380  65536  65536    60.02    9399.61   2.22     14.53    0.155
1.013 
87380  65536  65536    60.02    9348.01   2.46     14.39    0.173
1.009 
87380  65536  65536    60.02    9403.36   2.26     14.37    0.158
1.001 
87380  65536  65536    60.01    9332.22   2.23     14.51    0.157
1.019 


Bidirectional test.
87380  65536  65536    60.01   7809.57   28.66    30.02    2.405   2.519
TX
87380  65536  65536    60.01   7592.90   28.66    30.02    2.474   2.591
RX
------------------------------
87380  65536  65536    60.01  7629.73   28.32    29.64    2.433   2.546
RX
87380  65536  65536    60.01  7926.99   28.32    29.64    2.342   2.450
TX

Signle netperf stream between 2 quad-core Xeon based boxes. Tested on
2.6.20 and 2.6.22 kernels. Driver uses NAPI and LRO.

To summarize, we are seeing the line-rate with NAPI (single Rx queue)
and Rx CPU utilization is around 14%. In back to back scenarios, NAPI
(combined with LRO) performs clearly better. In multiple client
scenarios, Non-NAPI with multiple Rx queues performs better. I am
continuously doing more benchmarking and submit a patch to pick one this
week.

But going forward if NAPI supports multiple Rx queues natively, I
believe that would perform much better in most of the cases.

Also, did you get a chance to review the driver take #2? I like to
implement the review comments (if any) as early as possible, and submit
another version.

Thanks...

Ayyappan




    -
    To unsubscribe from this list: send the line "unsubscribe netdev" in
    the body of a message to majordomo@vger.kernel.org
    More majordomo info at  http://vger.kernel.org/majordomo-info.html
