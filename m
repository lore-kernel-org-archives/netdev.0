From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 17:49:40 +0530
Message-ID: <OF236C2BD3.D32DAA85-ON65257798.0042D7F4-65257798.00438120@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com> <OFB2808A12.59A863DC-ON65257798.002E987B-65257798.0033564B@in.ibm.com> <20100908104833.GJ23051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rick.jones2@hp.com, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100908104833.GJ23051@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 09/08/2010 04:18:33 PM:

>
_______________________________________________________________________________

> >
> > > >                            TCP (#numtxqs=2)
> > > > N#      BW1     BW2    (%)      SD1     SD2    (%)      RSD1
RSD2
> > (%)
> > > >
> > >
> >
>
_______________________________________________________________________________

> >
> > > > 4       26387   40716 (54.30)   20      28   (40.00)    86i     85
> > (-1.16)
> > > > 8       24356   41843 (71.79)   88      129  (46.59)    372     362
> > (-2.68)
> > > > 16      23587   40546 (71.89)   375     564  (50.40)    1558
1519
> > (-2.50)
> > > > 32      22927   39490 (72.24)   1617    2171 (34.26)    6694
5722
> > (-14.52)
> > > > 48      23067   39238 (70.10)   3931    5170 (31.51)    15823
13552
> > (-14.35)
> > > > 64      22927   38750 (69.01)   7142    9914 (38.81)    28972
26173
> > (-9.66)
> > > > 96      22568   38520 (70.68)   16258   27844 (71.26)   65944
73031
> > (10.74)
> > >
> > > That's a significant hit in TCP SD. Is it caused by the imbalance
between
> > > number of queues for TX and RX? Since you mention RX is complete,
> > > maybe measure with a balanced TX/RX?
> >
> > Yes, I am not sure why it is so high.
>
> Any errors at higher levels? Are any packets reordered?

I haven't seen any messages logged, and retransmission is similar
to non-mq case. Device also has no errors/dropped packets. Anything
else I should look for?

On the host:

# ifconfig vnet0
vnet0     Link encap:Ethernet  HWaddr 9A:9D:99:E1:CA:CE
          inet6 addr: fe80::989d:99ff:fee1:cace/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5090371 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5054616 errors:0 dropped:0 overruns:65 carrier:0
          collisions:0 txqueuelen:500
          RX bytes:237793761392 (221.4 GiB)  TX bytes:333630070 (318.1 MiB)
# netstat -s  |grep -i retrans
    1310 segments retransmited
    35 times recovered from packet loss due to fast retransmit
    1 timeouts after reno fast retransmit
    41 fast retransmits
    1236 retransmits in slow start

So retranmissions are 0.025% of total packets received from the guest.

Thanks,

- KK

