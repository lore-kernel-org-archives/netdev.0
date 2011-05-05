From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Thu, 5 May 2011 20:57:13 +0530
Message-ID: <OFB1ACC9EB.4567C1B1-ON65257887.0050044B-65257887.0054A5CE@in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com> <20110504144622.GA15823@redhat.com> <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com> <20110504212359.GA21446@redhat.com> <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com> <20110505090439.GD17647@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:53799 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361Ab1EEPYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 11:24:41 -0400
In-Reply-To: <20110505090439.GD17647@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 02:34:39 PM:

> > Do I need to apply all the patches and simply test?
> >
> > Thanks,
> >
> > - KK
>
> Exactly. You can also try to tune the threshold
> for interrupts as well.

I haven't tuned the threshhold, it is left it at 3/4. I ran
the new qemu/vhost/guest, and the results for 1K, 2K and 16K
are below. Note this is a different kernel version from my
earlier test results. So, f.e., BW1 represents 2.6.39-rc2,
the original kernel; while BW2 represents 2.6.37-rc5 (MST's
kernel). This also isn't with the fixes you have sent just
now. I will get a run with that either late tonight or
tomorrow.

________________________________________________________
                   I/O size: 1K
#     BW1     BW2 (%)        SD1       SD2 (%)
________________________________________________________
1     1723    3016 (75.0)    4.7       2.6 (-44.6)
2     3223    6712 (108.2)   18.0      7.1 (-60.5)
4     7223    8258 (14.3)    36.5      24.3 (-33.4)
8     8689    7943 (-8.5)    131.5     101.6 (-22.7)
16    8059    7398 (-8.2)    578.3     406.4 (-29.7)
32    7758    7208 (-7.0)    2281.4    1574.7 (-30.9)
64    7503    7155 (-4.6)    9734.0    6368.0 (-34.5)
96    7496    7078 (-5.5)    21980.9   15477.6 (-29.5)
128   7389    6900 (-6.6)    40467.5   26031.9 (-35.6)
________________________________________________________
Summary:     BW: (4.4)     SD: (-33.5)

________________________________________________________
                 I/O size: 2K
#     BW1     BW2 (%)        SD1       SD2 (%)
________________________________________________________
1     1608    4968 (208.9)   5.0       1.3 (-74.0)
2     3354    6974 (107.9)   18.6      4.9 (-73.6)
4     8234    8344 (1.3)     35.6      17.9 (-49.7)
8     8427    7818 (-7.2)    103.5     71.2 (-31.2)
16    7995    7491 (-6.3)    410.1     273.9 (-33.2)
32    7863    7149 (-9.0)    1678.6    1080.4 (-35.6)
64    7661    7092 (-7.4)    7245.3    4717.2 (-34.8)
96    7517    6984 (-7.0)    15711.2   9838.9 (-37.3)
128   7389    6851 (-7.2)    27121.6   18255.7 (-32.6)
________________________________________________________
Summary:     BW: (6.0)     SD: (-34.5)

________________________________________________________
                  I/O size: 16K
#     BW1     BW2 (%)        SD1       SD2 (%)
________________________________________________________
1     6684    7019 (5.0)     1.1       1.1 (0)
2     7674    7196 (-6.2)    5.0       4.8 (-4.0)
4     7358    8032 (9.1)     21.3      20.4 (-4.2)
8     7393    8015 (8.4)     82.7      82.0 (-.8)
16    7958    8366 (5.1)     283.2     310.7 (9.7)
32    7792    8113 (4.1)     1257.5    1363.0 (8.3)
64    7673    8040 (4.7)     5723.1    5812.4 (1.5)
96    7462    7883 (5.6)     12731.8   12119.8 (-4.8)
128   7338    7800 (6.2)     21331.7   21094.7 (-1.1)
________________________________________________________
Summary:     BW: (4.6)     SD: (-1.5)

Thanks,

- KK

