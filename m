From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 9 Sep 2010 18:48:31 +0530
Message-ID: <OF6AD3DC8F.0443E9CD-ON65257799.004585FA-65257799.0048E37E@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com> <OF70542242.6CAA236A-ON65257798.0044A4E0-65257798.005C0E7C@LocalDomain> <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@LocalDomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2/India/IBM wrote on 09/09/2010 03:15:53 PM:

> I will start a full test run of original vs submitted
> code with minimal tuning (Avi also suggested the same),
> and re-send. Please let me know if you need any other
> data.

Same patch, only change is that I ran "taskset -p 03
<all vhost threads>", no other tuning on host or guest.
Default netperf without any options. The BW is the sum
across two iterations, each is 60secs. Guest is started
with 2 txqs.

BW1/BW2: BW for org & new in mbps
SD1/SD2: SD for org & new
RSD1/RSD2: Remote SD for org & new
_______________________________________________________________________________
#    BW1       BW2    (%)        SD1    SD2   (%)      RSD1    RSD2  (%)
_______________________________________________________________________________
1    20903     19422  (-7.08)    1      1    (0)       6       7
(16.66)
2    21963     24330  (10.77)    6      6    (0)       25      25    (0)
4    22042     31841  (44.45)    23     28   (21.73)   102     110   (7.84)
8    21674     32045  (47.84)    97     111  (14.43)   419     421   (.47)
16   22281     31361  (40.75)    379    551  (45.38)   1663    2110
(26.87)
24   22521     31945  (41.84)    857    981  (14.46)   3748    3742  (-.16)
32   22976     32473  (41.33)    1528   1806  (18.19)  6594    6885  (4.41)
40   23197     32594  (40.50)    2390   2755  (15.27)  10239   10450 (2.06)
48   22973     32757  (42.58)    3542   3786  (6.88)   15074   14395
(-4.50)
64   23809     32814  (37.82)    6486   6981  (7.63)   27244   26381
(-3.16)
80   23564     32682  (38.69)    10169  11133 (9.47)   43118   41397
(-3.99)
96   22977     33069  (43.92)    14954  15881 (6.19)   62948   59071
(-6.15)
128  23649     33032  (39.67)    27067  28832 (6.52)   113892  106096
(-6.84)
_______________________________________________________________________________
     294534    400371 (35.9)     67504  72858 (7.9)    285077  271096
(-4.9)
_______________________________________________________________________________

I will try more tuning later as Avi suggested, wanted to test
the minimal for now.

Thanks,

- KK

