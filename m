From: "Richard Bollinger" <rabollinger@gmail.com>
Subject: Re: tg3 driver fails with on-board BCM95789 NICS (GigaByte GA-7VCSV)
Date: Wed, 25 Oct 2006 09:02:42 -0400
Message-ID: <7744a2840610250602m4b589fedq3a4e89f26fc18794@mail.gmail.com>
References: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
	 <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:65366 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S965082AbWJYNCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 09:02:45 -0400
Received: by ug-out-1314.google.com with SMTP id 32so82367ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 06:02:43 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/06, Michael Chan <mchan@broadcom.com> wrote:
> ...
> Can you cat /proc/interrupts a few times to see if the interrupt
> counts on eth1 and eth2 are increasing?
# grep eth /proc/interrupts
  9:          0          0          0          0    IO-APIC-edge  eth2
 16:     177724          0     371238      19350   IO-APIC-level
libata, eth0, eth1
# ifconfig eth1;ifconfig eth2
eth1      Link encap:Ethernet  HWaddr 00:16:E6:80:B1:3E
          inet addr:128.1.9.0  Bcast:128.1.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:15276 errors:0 dropped:0 overruns:0 frame:0
          TX packets:30 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1389350 (1.3 Mb)  TX bytes:1920 (1.8 Kb)
          Interrupt:16

eth2      Link encap:Ethernet  HWaddr 00:16:E6:80:B1:3F
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:9

>
> You can also run ethtool -t [eth1 | eth2] to run a basic selftest
> on the 2 devices.  Be sure to ifconfig up first before the selftest.
# ethtool -t eth1
The test result is PASS
The test extra info:
nvram test     (online)          0
link test      (online)          0
register test  (offline)         0
memory test    (offline)         0
loopback test  (offline)         0
interrupt test (offline)         0

# ethtool -t eth2
The test result is FAIL
The test extra info:
nvram test     (online)          0
link test      (online)          1
register test  (offline)         0
memory test    (offline)         0
loopback test  (offline)         0
interrupt test (offline)         1
