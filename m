From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Thu, 17 Sep 2015 18:03:20 -0400
Message-ID: <CAHQdGtRy3_DSrUNNBy7+mSxC=a5X=yHME84mp2rVrYk9KhsMVg@mail.gmail.com>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	<1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150911143347.GQ21084@n2100.arm.linux.org.uk>
	<20150911150613.GR21084@n2100.arm.linux.org.uk>
	<1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150911162416.GV21084@n2100.arm.linux.org.uk>
	<20150911164937.GW21084@n2100.arm.linux.org.uk>
	<20150917135705.GQ21084@n2100.arm.linux.org.uk>
	<1442499509.2865.16.camel@primarydata.com>
	<20150917214758.GW21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: AnnaSchumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ARM Kernel Mailing List
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150917214758.GW21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 17, 2015 at 5:47 PM, Russell King - ARM Linux
<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org> wrote:
> On Thu, Sep 17, 2015 at 10:18:29AM -0400, Trond Myklebust wrote:
>> Hi Russell,
>>
>> On Thu, 2015-09-17 at 14:57 +0100, Russell King - ARM Linux wrote:
>> > On Fri, Sep 11, 2015 at 05:49:38PM +0100, Russell King - ARM Linux
>> > wrote:
>> > > Following that idea, I just tried the patch below, and it seems =
to
>> > > work.
>> > > I don't know whether it handles all cases after a call to
>> > > kernel_connect(),
>> > > but it stops the multiple connection attempts:
>> > >
>> > >   1   0.000000 armada388 -> n2100 TCP 1009=E2=86=92nfs [SYN] Seq=
=3D3794066539
>> > > Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D15712 TSecr=
=3D870317691
>> > > WS=3D128
>> > >   2   0.000414 n2100 -> armada388 TCP nfs=E2=86=921009 [SYN, ACK=
]
>> > > Seq=3D1884476522 Ack=3D3794066540 Win=3D28560 Len=3D0 MSS=3D1440=
 SACK_PERM=3D1
>> > > TSval=3D870318939 TSecr=3D15712 WS=3D64
>> > >   3   0.000787 armada388 -> n2100 TCP 1009=E2=86=92nfs [ACK] Seq=
=3D3794066540
>> > > Ack=3D1884476523 Win=3D28672 Len=3D0 TSval=3D15712 TSecr=3D87031=
8939
>> > >   4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0x905379cc, [Check: RD LU MD XT DL]
>> > >   5   0.001566 n2100 -> armada388 TCP nfs=E2=86=921009 [ACK] Seq=
=3D1884476523
>> > > Ack=3D3794066660 Win=3D28608 Len=3D0 TSval=3D870318939 TSecr=3D1=
5712
>> > >   6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0x905379cc, [Check: RD LU MD XT DL]
>> > >   7   0.001866 n2100 -> armada388 TCP nfs=E2=86=921009 [ACK] Seq=
=3D1884476523
>> > > Ack=3D3794066780 Win=3D28608 Len=3D0 TSval=3D870318939 TSecr=3D1=
5712
>> > >   8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4=
),
>> > > [Allowed: RD LU MD XT DL]
>> > >   9   0.003415 armada388 -> n2100 TCP 1009=E2=86=92nfs [ACK] Seq=
=3D3794066780
>> > > Ack=3D1884476647 Win=3D28672 Len=3D0 TSval=3D15712 TSecr=3D87031=
8939
>> > >  10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0xe15fc9c9, [Check: RD LU MD XT DL]
>> > >  11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6=
),
>> > > [Allowed: RD LU MD XT DL]
>> > >  12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH:
>> > > 0xe15fc9c9, [Check: RD LU MD XT DL]
>> > >  13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 1=
0),
>> > > [Allowed: RD LU MD XT DL]
>> > >  14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH:
>> > > 0xe15fc9c9
>> > > ...
>> >
>> > NFS people - any comments on this patch?  Is it the correct way to
>> > solve
>> > this problem (please see the first message in this thread for the
>> > problem.)
>> > Without this patch, NFS is unusable as it tries to launch multiple
>> > new
>> > connections from the same port to the NFS server without giving th=
e
>> > NFS
>> > server time to respond and establish the TCP connection.
>>
>> I agree that it addresses a real problem here, however there are a
>> couple of issues with the patch itself:
>>
>> AFAICS, the 2 possible next states for SYN_SENT are TCP_ESTABLISHED =
and
>> TCP_CLOSE, so if the connection attempt fails, this patch leaves the
>> XPRT_CONNECTING flag set.
>> There is also the issue that clearing XPRT_CONNECTING in TCP_FIN_WAI=
T1,
>> TCP_CLOSE_WAIT and TCP_CLOSING could interfere with another connecti=
on
>> attempt by canceling the XPRT_CONNECTING state.
>>
>> How about the following? It is based on your patch, but adds a check=
 to
>> ensure that xs_tcp_state_change() doesn't clear the 'connecting' sta=
te
>> more than once (which could otherwise still happen in the TCP_CLOSE
>> case).
>
> This patch also seems to fix the problem I've been seeing.
>
> Yes, I wasn't sure about my patch - I didn't spend much time properly
> reading and understanding the sunrpc code, beyond analysing what was
> going on to cause the problem and deciding on a way to stop it happen=
ing.
> I really wasn't sure that clearing the connecting flag everywhere I d=
id
> was the right thing, which is why I didn't send the patch properly
> dressed up.
>
>> 8<------------------------------------------------------------------=
-
>> >From 4dbfdebbc09982a9248866f8256549456e2b2efd Mon Sep 17 00:00:00 2=
001
>> From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
>> Date: Wed, 16 Sep 2015 23:43:17 -0400
>> Subject: [PATCH] SUNRPC: Ensure that we wait for connections to comp=
lete
>>  before retrying
>>
>> Commit 718ba5b87343, moved the responsibility for unlocking the sock=
et to
>> xs_tcp_setup_socket, meaning that the socket will be unlocked before=
 we
>> know that it has finished trying to connect. The following patch is =
based on
>> an initial patch by Russell King to ensure that we delay clearing th=
e
>> XPRT_SOCK_CONNECTING flag until we either know that we failed to ini=
tiate
>> a connection attempt, or the connection attempt itself failed.
>>
>> Fixes: 718ba5b87343 ("SUNRPC: Add helpers to prevent socket create f=
rom racing")
>> Reported-by: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
>
> Reported-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> Tested-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
>

Thanks Russell!
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
