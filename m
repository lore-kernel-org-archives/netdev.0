From: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
Subject: Re: How can we bound one CPU to one Gigabit NIC?
Date: Tue, 8 Oct 2002 00:27:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <010001c26e9c$2319c480$f5f2010a@weixl>
References: <Pine.GSO.4.30.0210070749430.1861-100000@shell.cyberus.ca> <03ab01c26e2d$06adeac0$f5f2010a@weixl> <3DA1D15C.1070309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ben Greear" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    Thank you Ben.
    I did some UDP test with Iperf.  Here are the results:
    Without bounding CPU, I had thousands of pakcets out of order in
1.7GByte* 2 connection transmission, with standard MTU. The throughput is
about 550Mbps*2 (connection) with UDP packets. The sender can send 800Mbps
for each connection.
    With CPU bounding, I had no packet out of order. Anyway, the two
connections got only 1.3~1.4 throughput totally.  The senders seemed to be
able to send 1.6Gbps totally. (So, it seems that receiving packets takes
more time than sending packets)
     Anyway, for a single connection on these machines, I could get 950Mbps.
Is there any suggestion to improve the Dual CPU-Dual NIC performance? I
looked at the "top". The two Iperf processes seemed to be using more than
60% CPU each. That means they are using different CPU. Anyway, I am not sure
if they migrated from one CPU to the other very often or not. If they
changed very often, it may resulted in the low performance, I guess. Is
there anyway to bound a process to a specific CPU?
    The machines are with Dual Xeon 2.2 G CPU and Dual SysKonnect
Gigabit-Ethernet Card. All the tests were done with UDP. (Iperf -s -u /
Iperf -c -u -b1.7G.)
    Thanks.

-David
Xiaoliang (David) Wei             Graduate Student in CS@Caltech
http://www.cs.caltech.edu/~weixl
====================================================
----- Original Message -----
From: "Ben Greear" <greearb@candelatech.com>
To: "Xiaoliang (David) Wei" <weixl@caltech.edu>
Cc: <netdev@oss.sgi.com>
Sent: Monday, October 07, 2002 11:24 AM
Subject: Re: How can we bound one CPU to one Gigabit NIC?


> Xiaoliang (David) Wei wrote:
> > Hi Everyone,
> >       I am now doing some experiments on Dual CPU (2.4Ghz) with 2
Gigabit
> > cards. Can anyone tell me how to bound one CPU to each NIC so that we
don't
> > need to care about the packet-reordering and the interrupt sharing
problems?
> >       Thank you very much.:)
>
> My experiments show you will still get re-ordered packets occasionally
> (but then again, I'm having other wierd problems, so maybe you wont).
>
> # Bind processor 2 (1<<1) to irq 11
> echo 2 > /proc/irq/11/smp_affinity
>
> # Bind processor 1 (1<<0) to irq 19
> echo 1 > /proc/irq/9/smp_affinity
>
>
> I will be interested to hear of your results, as I have been having
> heating problems with e1000 and other problems with tg3 based nics!
>
> Ben
>
> >
> >
> >
> > Xiaoliang (David) Wei             Graduate Student in CS@Caltech
> > http://www.cs.caltech.edu/~weixl
> > ====================================================
> >
>
>
> --
> Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
> President of Candela Technologies Inc      http://www.candelatech.com
> ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
>
>
>
>
