From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Fri, 8 Jul 2005 11:17:29 -0700
Message-ID: <000201c583e9$4dad0350$3910100a@pc.s2io.com>
References: <Pine.LNX.4.61.0507080816070.24321@resonance.WorkGroup>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>, <netdev@vger.kernel.org>,
        <leonid.grossman@neterion.com>, <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Arthur Kepner'" <akepner@sgi.com>,
        "'Raghavendra Koushik'" <raghavendra.koushik@neterion.com>
In-Reply-To: <Pine.LNX.4.61.0507080816070.24321@resonance.WorkGroup>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arthur/David/Jeff,
Thanks for pointing that out. We will wait for any other comments
on our 12 patches. If there are no other, will send out a patch13
to include the mmiowb() change.

Thanks,
Ravi

-----Original Message-----
From: Arthur Kepner [mailto:akepner@sgi.com]
Sent: Friday, July 08, 2005 8:31 AM
To: Raghavendra Koushik
Cc: jgarzik@pobox.com; netdev@oss.sgi.com; netdev@vger.kernel.org;
ravinandan.arakali@neterion.com; leonid.grossman@neterion.com;
rapuru.sriram@neterion.com
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements


On Thu, 7 Jul 2005, Raghavendra Koushik wrote:

> ....
> On an Altix machine I believe the readq was necessary to flush 
> the PIO writes. How long did you run the tests? I had seen
> in long duration tests that an occasional write 
> (TXDL control word and the address) would be missed and the xmit
> Get's stuck.
> 

The most recent tests I did used pktgen, and they ran for a total 
time of ~.5 hours (changing pkt_size every 30 seconds or so). The 
pktgen tests and other tests (like nttcp) have been run several times, 
so I've exercised the card for a total of several hours without 
any problems.

> 
> > 
> > FWIW, I've done quite a few performance measurements with the patch 
> > I posted earlier, and it's worked well. For 1500 byte mtus throughput 
> > goes up by ~20%. Is even the mmiowb() unnecessary?
> > 
> 
> Was this on 2.4 kernel because I think the readq would not have a 
> significant impact on 2.6 kernels due to TSO.
> (with TSO on the number of packets that actually enter the 
> Xmit routine would be reduced apprx 40 times).
> .....

This was with a 2.6 kernel (with TSO on). PIO reads are pretty 
expensive on Altix, so eliminating them really helps us. 

For big mtus (>=4KBytes) the benefit of replacing the readq()
with mmiowb() in s2io_xmit() is negligible. 

--
Arthur
