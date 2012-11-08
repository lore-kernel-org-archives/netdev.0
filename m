From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Thu, 8 Nov 2012 20:35:48 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
References: <509B5038.8090304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: Joe Jin <joe.jin@oracle.com>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509B5038.8090304@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Joe Jin
>Sent: Wednesday, November 07, 2012 10:25 PM
>To: e1000-devel@lists.sf.net
>Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Mary Mcgrath
>Subject: 82571EB: Detected Hardware Unit Hang
>
>Hi list,
>
>IHAC reported "82571EB Detected Hardware Unit Hang" on HP ProLiant DL360
>G6, and have to reboot the server to recover:
>
>e1000e 0000:06:00.1: eth3: Detected Hardware Unit Hang:
>  TDH                  <1a>
>  TDT                  <1a>
>  next_to_use          <1a>
>  next_to_clean        <18>
>buffer_info[next_to_clean]:
>  time_stamp           <10047a74e>
>  next_to_watch        <18>
>  jiffies              <10047a88c>
>  next_to_watch.status <1>
>MAC Status             <80383>
>PHY Status             <792d>
>PHY 1000BASE-T Status  <3800>
>PHY Extended Status    <3000>
>PCI Status             <10>
>
>With newer kernel 2.0.0.1 the issue still reproducible.
>
>Device info:
>06:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (Copper) (rev 06)
>06:00.1 0200: 8086:10bc (rev 06)
>
>I compared lspci output before and after the issue, different as below:
> 06:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (Copper) (rev 06)
> 	Subsystem: Hewlett-Packard Company NC364T PCI Express Quad Port
>Gigabit Server Adapter
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
>Stepping- SERR- FastB2B- DisINTx-
>-	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
><TAbort- <MAbort- >SERR- <PERR- INTx-
>+	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>+<TAbort- <MAbort- >SERR- <PERR- INTx+

Are you sure this is not similar issue as before that you reported.
i.e. 
On Mon, 2012-07-09 at 16:51 +0800, Joe Jin wrote:
> I'm seeing a Unit Hang even with the latest e1000e driver 2.0.0 when 
> doing scp test. this issue is easy do reproduced on SUN FIRE X2270 M2, 
> just copy a big file (>500M) from another server will hit it at once.

All devices in path from root complex to 82571, should have *same* max payload size otherwise it can cause hang. 
Can you double check this?

-Tushar
