From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: Problems with ixgbe driver
Date: Fri, 14 Jun 2013 16:08:04 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FDC4748@FMSMSX105.amr.corp.intel.com>
References: <alpine.LRH.2.02.1306141031490.22892@praktifix.dwd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Holger Kiehl <Holger.Kiehl@dwd.de>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.02.1306141031490.22892@praktifix.dwd.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Holger Kiehl
>Sent: Friday, June 14, 2013 4:50 AM
>To: e1000-devel@lists.sf.net
>Cc: linux-kernel; netdev@vger.kernel.org
>Subject: Problems with ixgbe driver
>
>Hello,
>
>I have dual port 10Gb Intel network card on a 2 socket (Xeon X5690) with
>a total of 12 cores. Hyperthreading is enabled so there are 24 cores.
>The problem I have is that when other systems send large amount of data
>the network with the intel ixgbe driver gets very slow. Ping times go up
>from 0.2ms to appr. 60ms. Some FTP connections stall for more then 2
>minutes. What is strange is that heatbeat is configured on the system
>with a serial connection to another node and kernel always reports

If the network slows down so much there should be some indication in dmesg. Like Tx hangs perhaps.
Can you provide the output of dmesg and ethtool -S from the offending interface after the issue occurs?

>
>     ttyS0: 4 input overrun(s)
>
>when lot of data is send and the ping time goes up.
>
>On the network there are three vlan's configured. The network is bonded
>(active-backup) together with another HP NC523SFP 10Gb 2-port Server
>Adapter. When I switch the network to this card the problem goes away.
>Also the ttyS0 input overruns disappear. Note also both network cards
>are connected to the same switch.
>
>The system uses Scientific Linux 6.4 with kernel.org kernel. I noticed
>this behavior with kernel 3.9.5 and 3.9.6-rc1. Before I did not notice
>it because traffic always went over the HP NC523SFP qlcnic card.
>
>In search for a solution to the problem I found a newer ixgbe driver
>3.15.1 (3.9.6-rc1. has 3.11.33-k) and tried that. But it has the same
>problem. However when I load the module as follows:
>
>     modprobe ixgbe RSS=8,8
>
>the problem goes away. The kernel.org ixgbe driver does not offer this
>option. Why? It seems that both drivers have problems on systems with

If you are using newer kernel and ethtool version you can use `ethtool -L ethX combined Y` to control the number of queues per interface.

>24 cpu's. But I cannot believe that I am the only one who noticed this,
>since ixgbe is widely used.

We run traffic with multiple queues all the time and I don't think what you are reporting is a generic issue. Most likely it's something related to your setup/system.

>
>It would really be nice if one could set the RSS=8,8 option for kernel.org
>ixgbe driver too. Or if someone could tell me where I can force the driver
>to Receive Side Scaling to 8 even if it means editing the source code.
>
>Below I have added some additional information. Please CC me since I
>am not subscribed to any of these lists. And please do not hesitate
>to ask if more information is needed.

I would suggest that you open up a bug at e1000.sf.net - describe your configuration and attach the relevant info (dmesg, ethtool -S, lspci etc). This would make it easier for us to follow.

Thanks,
Emil
