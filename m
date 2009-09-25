From: Joe Cao <caoco2002@yahoo.com>
Subject: Re: TCP stack bug related to F-RTO?
Date: Thu, 24 Sep 2009 23:42:45 -0700 (PDT)
Message-ID: <511432.48405.qm@web63401.mail.re1.yahoo.com>
References: <40c9f5b20909241932k5e1f1d74kf8065e2e06aa4d09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jcaoco2002@yahoo.com,
	netdev@vger.kernel.org
To: zhigang gong <zhigang.gong@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752229AbZIYGmn@vger.kernel.org>
In-Reply-To: <40c9f5b20909241932k5e1f1d74kf8065e2e06aa4d09@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On the wrong tcp checksum, that's because of hardware checksum offload.

As for the seq/ack number, because the trace is long, I deliberately re=
moved those irrelevant packets between after the three-way handshake an=
d when the problem happens.  That can be seen from the timestamps.

Please also note that I intentionally replaced the IP addresses and mac=
 addresses in the trace to hide proprietary information in the trace.

Anyway, the problem is not related to the checksum, or seq/ack number, =
otherwise, you won't see the behavior shown in the trace.

Thanks,
Joe

--- On Thu, 9/24/09, zhigang gong <zhigang.gong@gmail.com> wrote:

> From: zhigang gong <zhigang.gong@gmail.com>
> Subject: Re: TCP stack bug related to F-RTO?
> To: "Joe Cao" <caoco2002@yahoo.com>
> Cc: linux-kernel@vger.kernel.org, jcaoco2002@yahoo.com, netdev@vger.k=
ernel.org
> Date: Thursday, September 24, 2009, 7:32 PM
> On Fri, Sep 25, 2009 at 1:43 AM, Joe
> Cao <caoco2002@yahoo.com>
> wrote:
> > Hello,
> >
> > I have found the following behavior with different
> versions of linux kernel. The attached pcap trace is
> collected with server (192.168.0.13) running 2.6.24 and
> shows the problem. Basically the behavior is like this:
> >
> > 1. The client opens up a big window,
> > 2. the server sends 19 packets in a row (pkt #14- #32
> in the trace), but all of them are dropped due to some
> congestion.
> > 3. The server hits RTO and retransmits pkt #14 in #33
> > 4. The client immediately acks #33 (=3D#14), and the
> server (seems like to enter F-RTO) expends the window and
> sends *NEW* pkt #35 & #36.=3DA0 Timeoute is doubled to
> 2*RTO; The client immediately sends two Dup-ack to #35 and
> #36.
> > 5. after 2*RTO, pkt #15 is retransmitted in #39.
> > 6. The client immediately acks #39 (=3D#15) in #40, and
> the server continues to expand the window and sends two
> *NEW* pkt #41 & #42. Now the timeoute is doubled to 4
> *RTO.
> > 8. After 4*RTO timeout, #16 is retransmitted.
> > 9....
> > 10. The above steps repeats for retransmitting pkt
> #16-#32 and each time the timeout is doubled.
> > 11. It takes a long long time to retransmit all the
> lost packets and before that is done, the client sends a RST
> because of timeout.
> >
> > The above behavior looks like F-RTO is in effect.
> =A0And there seems to be a bug in the TCP's congestion
> control and
> > retransmission algorithm. Why doesn't the TCP on
> server (running 2.6.24) enter the slow start?
> As I know, the early implementation hasn't enter slow start
> if the
> remote end is in the same network.=A0 I'm not sure that
> of the version
> 2.6.24. But after I have a look at your trace, I think this
> is not the
> point of your problem. The behaviour of your client
> 192.168.0.82 is
> very strange. The client always send a packet with error
> TCP checksum
> and the 4# to 13# packets sent by the
> client=A0=A0=A0totally don't conform
> to=A0 the TCP protocol, not only with wrong TCP checksum
> but also with
> incorrect seq and ack number.
>=20
> My suggestion is that before you start to investigate the
> server
> side's behaviour, you need to correct your client side's
> TCP/IP stack
> implementation first.
>=20
> >Why should the server take that long to recover from a
> short period of packet loss?
>=20
> >
> > Has anyone else noticed similar problem before? =A0If
> my analysis was wrong, can anyone gives me some pointers to
> what's really wrong and how to fix it?
> >
> > Thanks a lot,
> > Joe
> >
> > PS. Please cc me when this message is replied.
> >
> >
> >
>=20


     =20
