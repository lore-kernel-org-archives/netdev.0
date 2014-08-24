From: Razya Ladelsky <RAZYA@il.ibm.com>
Subject: RE: [PATCH] vhost: Add polling mode
Date: Sun, 24 Aug 2014 15:26:34 +0300
Message-ID: <OF3F9F58DB.FFDF5B60-ONC2257D3E.00443320-C2257D3E.004449BE@il.ibm.com>
References: <1407659404-razya@il.ibm.com>
	<20140810083035.0CF58380729@moren.haifa.ibm.com>
	<20140820105710.GC17371@redhat.com>
	<OFBE98487F.0F49BDD7-ONC2257D3B.004C908C-C2257D3B.004F09FD@il.ibm.com>
	<063D6719AE5E284EB5DD2968C1650D6D1747D7F3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eran Raichstein <ERANRA@il.ibm.com>, Alex Glikson <GLIKSON@il.ibm.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"abel.gordon@gmail.com" <abel.gordon@gmail.com>,
	Yossi Kuperman1 <YOSSIKU@il.ibm.com>, Joel Nider <JOELN@il.ibm.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1747D7F3@AcuExch.aculab.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> wrote on 21/08/2014 05:29:41 PM:

> From: David Laight <David.Laight@ACULAB.COM>
> To: Razya Ladelsky/Haifa/IBM@IBMIL, "Michael S. Tsirkin" 
<mst@redhat.com>
> Cc: "abel.gordon@gmail.com" <abel.gordon@gmail.com>, Alex Glikson/
> Haifa/IBM@IBMIL, Eran Raichstein/Haifa/IBM@IBMIL, Joel Nider/Haifa/
> IBM@IBMIL, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-
> kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
> "netdev@vger.kernel.org" <netdev@vger.kernel.org>, 
> "virtualization@lists.linux-foundation.org" 
> <virtualization@lists.linux-foundation.org>, Yossi 
Kuperman1/Haifa/IBM@IBMIL
> Date: 21/08/2014 05:31 PM
> Subject: RE: [PATCH] vhost: Add polling mode
> 
> From: Razya Ladelsky
> > "Michael S. Tsirkin" <mst@redhat.com> wrote on 20/08/2014 01:57:10 PM:
> > 
> > > > Results:
> > > >
> > > > Netperf, 1 vm:
> > > > The polling patch improved throughput by ~33% (1516 MB/sec -> 
> 2046 MB/sec).
> > > > Number of exits/sec decreased 6x.
> > > > The same improvement was shown when I tested with 3 vms running 
netperf
> > > > (4086 MB/sec -> 5545 MB/sec).
> > > >
> > > > filebench, 1 vm:
> > > > ops/sec improved by 13% with the polling patch. Number of exits
> > > > was reduced by 31%.
> > > > The same experiment with 3 vms running filebench showed similar 
numbers.
> > > >
> > > > Signed-off-by: Razya Ladelsky <razya@il.ibm.com>
> > >
> > > This really needs more thourough benchmarking report, including
> > > system data.  One good example for a related patch:
> > > http://lwn.net/Articles/551179/
> > > though for virtualization, we need data about host as well, and if 
you
> > > want to look at streaming benchmarks, you need to test different 
message
> > > sizes and measure packet size.
> > >
> > 
> > Hi Michael,
> > I have already tried running netperf with several message sizes:
> > 64,128,256,512,600,800...
> > But the results are inconsistent even in the baseline/unpatched
> > configuration.
> > For smaller msg sizes, I get consistent numbers. However, at some 
point,
> > when I increase the msg size
> > I get unstable results. For example, for a 512B msg, I get two 
scenarios:
> > vm utilization 100%, vhost utilization 75%, throughput ~6300
> > vm utilization 80%, vhost utilization 13%, throughput ~9400 (line 
rate)
> > 
> > I don't know why vhost is behaving that way for certain message sizes.
> > Do you have any insight to why this is happening?
> 
> Have you tried looking at the actual ethernet packet sizes.
> It may well jump between using small packets (the size of the writes)
> and full sized ones.

I will check it,
Thanks,
Razya

> 
> If you are trying to measure ethernet packet 'cost' you need to use UDP.
> However that probably uses different code paths.
> 
>    David
> 
> 
> 
