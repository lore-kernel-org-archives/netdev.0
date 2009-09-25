From: Joe Cao <caoco2002@yahoo.com>
Subject: Re: TCP stack bug related to F-RTO?
Date: Fri, 25 Sep 2009 09:02:19 -0700 (PDT)
Message-ID: <619356.98592.qm@web63403.mail.re1.yahoo.com>
References: <40c9f5b20909250155l49ad5fd2if8efb4fd48ed6066@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jcaoco2002@yahoo.com,
	netdev@vger.kernel.org
To: zhigang gong <zhigang.gong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n1b.bullet.mail.ac4.yahoo.com ([76.13.13.71]:30098 "HELO
	n1b.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753410AbZIYQCQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 12:02:16 -0400
In-Reply-To: <40c9f5b20909250155l49ad5fd2if8efb4fd48ed6066@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zhigang,

Thanks for help looking into the issue.

My answer to your analysis is of course there won't the third dup-ack, =
because the server only sends TWO NEW data packets every time.  Clearly=
 this is server's problem and not the client's problem.

Thanks,
Joe

--- On Fri, 9/25/09, zhigang gong <zhigang.gong@gmail.com> wrote:

> From: zhigang gong <zhigang.gong@gmail.com>
> Subject: Re: TCP stack bug related to F-RTO?
> To: "Joe Cao" <caoco2002@yahoo.com>
> Cc: linux-kernel@vger.kernel.org, jcaoco2002@yahoo.com, netdev@vger.k=
ernel.org
> Date: Friday, September 25, 2009, 1:55 AM
> Oh, I see, so I spoke too quickly in
> last mail. You just ignore some packets
> in the trace. I have analysed the traffic flow=A0 and
> have some findings as below,
> hope it's helpful.
>=20
> >> > 1. The client opens up a big window,
> >> > 2. the server sends 19 packets in a row (pkt
> #14- #32
> >> in the trace), but all of them are dropped due to
> some
> >> congestion.
> >> > 3. The server hits RTO and retransmits pkt
> #14 in #33
> This retransmission timer expiring indicate the server's
> tcp/ip
> stack to enter slow start mode, as a result we can see the
> server's sending window will be reduced to one.
>=20
> >> > 4. The client immediately acks #33 (=3D#14),
> and the
> >> server (seems like to enter F-RTO) expends the
> window and
> >> sends *NEW* pkt #35 & #36.=3DA0 Timeoute is
> doubled to
> >> 2*RTO; The client immediately sends two Dup-ack to
> #35 and
> >> #36.
>=20
> Server is still in slow start mode, and extend window to
> 2.
>=20
> >> > 5. after 2*RTO, pkt #15 is retransmitted in
> #39.
>=20
> Here , the second retransmission timer expiring ocur.
> Server's sending
> window reduce to one again and continue in slow start
> mode.
>=20
> >> > 6.. The client immediately acks #39 (=3D#15) in
> #40, and
> >> the server continues to expand the window and
> sends two
> >> *NEW* pkt #41 & #42. Now the timeoute is
> doubled to 4
> >> *RTO.
> Here you ignore two duplicate acks #37 and #38 sent by the
> client. As I know
> the server must receive three or even more duplcate acks
> before it enter fast
> retransmit mode, otherwise it will still in slow start mode
> and=A0 it
> will wait until next
> time retransmission timer expiring before retransmit the
> lost packets.
> And this is
> actually what you got.
>=20
> I'm not an kernel expert, I just analyse from the TCP
> protocol standard. From my
> view, I think there is no problem in the server's network
> stack. But
> there maybe
> some problem in the client (or some intermediate network
> appliance) side, as it
> always just sends two duplicate acks at the same time, and
> never send the third
> one no matter how long the interval is. In my opinion, if
> the client
> can send the third
> duplicate acks then the server will enter fast retransmit
> mode and
> then fast recovery
> then every thing will be ok.
>=20
> >> > 8. After 4*RTO timeout, #16 is
> retransmitted.
> >> > 9....
> >> > 10. The above steps repeats for
> retransmitting pkt
> >> #16-#32 and each time the timeout is doubled.
> >> > 11. It takes a long long time to retransmit
> all the
> >> lost packets and before that is done, the client
> sends a RST
> >> because of timeout.
>=20
> On Fri, Sep 25, 2009 at 2:42 PM, Joe Cao <caoco2002@yahoo.com>
> wrote:
> > Hi,
> >
> > On the wrong tcp checksum, that's because of hardware
> checksum offload.
> >
> > As for the seq/ack number, because the trace is long,
> I deliberately removed those irrelevant packets between
> after the three-way handshake and when the problem happens.
> =A0That can be seen from the timestamps.
> >
> > Please also note that I intentionally replaced the IP
> addresses and mac addresses in the trace to hide proprietary
> information in the trace.
> >
> > Anyway, the problem is not related to the checksum, or
> seq/ack number, otherwise, you won't see the behavior shown
> in the trace.
> >
> > Thanks,
> > Joe
> >
> > --- On Thu, 9/24/09, zhigang gong <zhigang.gong@gmail.com>
> wrote:
> >
>=20


     =20

