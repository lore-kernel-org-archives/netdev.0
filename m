From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 28 Oct 2010 12:48:57 +0530
Message-ID: <OFE75E1E91.9722BFB3-ON652577CA.00256D94-652577CA.0027E1CE@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101025161718.GA19559@redhat.com> <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain> <OFBB51646E.01CC3630-ON652577C8.0030D6EF-652577C8.0031DA3C@in.ibm.com> <20101026093846.GA6766@redhat.com> <OFBE9E2C99.648EFB19-ON652577C8.0035FEDD-652577C8.0036AD51@in.ibm.com> <20101026110913.GC7922@redhat.com> <OFC29C4491.59069AD1-ON652577CA.00170F0D-652577CA.001C76C8@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OFC29C4491.59069AD1-ON652577CA.00170F0D-652577CA.001C76C8@LocalDomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Krishna Kumar2/India/IBM wrote on 10/28/2010 10:44:14 AM:
>
> > > > > Results for UDP BW tests (unidirectional, sum across
> > > > > 3 iterations, each iteration of 45 seconds, default
> > > > > netperf, vhosts bound to cpus 0-3; no other tuning):
> > > >
> > > > Is binding vhost threads to CPUs really required?
> > > > What happens if we let the scheduler do its job?
> > >
> > > Nothing drastic, I remember BW% and SD% both improved a
> > > bit as a result of binding.
> >
> > If there's a significant improvement this would mean that
> > we need to rethink the vhost-net interaction with the scheduler.
>
> I will get a test run with and without binding and post the
> results later today.

Correction: The result with binding is is much better for
SD/CPU compared to without-binding:

_____________________________________________________
     numtxqs=8,vhosts=5, Bind vs No-bind
#     BW%     CPU%     RCPU%     SD%       RSD%
_____________________________________________________
1     11.25     10.77    1.89     0        -6.06
2     18.66     7.20     7.20    -14.28    -7.40
4     4.24     -1.27     1.56    -2.70     -.98
8     14.91    -3.79     5.46    -12.19    -3.76
16    12.32    -8.67     4.63    -35.97    -26.66
24    11.68    -7.83     5.10    -40.73    -32.37
32    13.09    -10.51    6.57    -51.52    -42.28
40    11.04    -4.12     11.23   -50.69    -42.81
48    8.61     -10.30    6.04    -62.38    -55.54
64    7.55     -6.05     6.41    -61.20    -56.04
80    8.74     -11.45    6.29    -72.65    -67.17
96    9.84     -6.01     9.87    -69.89    -64.78
128   5.57     -6.23     8.99    -75.03    -70.97
_____________________________________________________
BW: 10.4%,  CPU/RCPU: -7.4%,7.7%,  SD: -70.5%,-65.7%

Notes:
    1.  All my test results earlier was binding vhost
        to cpus 0-3 for both org and new kernel.
    2.  I am not using MST's use_mq patch, only mainline
        kernel. However, I reported earlier that I got
        better results with that patch. The result for
        MQ vs MQ+use_mm patch (from my earlier mail):

BW: 0   CPU/RCPU: -4.2,-6.1  SD/RSD: -13.1,-15.6

Thanks,

- KK

