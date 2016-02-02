From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Tue, 02 Feb 2016 12:35:06 -0800
Message-ID: <1454445306.7627.204.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
	 <1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?ISO-8859-1?Q?P=E5l?= Halvorsen <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad
	<bro.devel+kernel@gmail.com>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36718 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016AbcBBUfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 15:35:09 -0500
Received: by mail-pa0-f42.google.com with SMTP id yy13so104602739pab.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 12:35:08 -0800 (PST)
In-Reply-To: <1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-02 at 20:23 +0100, Bendik R=C3=B8nning Opstad wrote:
> RDB is a mechanism that enables a TCP sender to bundle redundant
> (already sent) data with TCP packets containing new data. By bundling
> (retransmitting) already sent data with each TCP packet containing ne=
w
> data, the connection will be more resistant to sporadic packet loss
> which reduces the application layer latency significantly in congeste=
d
> scenarios.
>=20
> The main functionality added:
>=20
>   o Loss detection of hidden loss events: When bundling redundant dat=
a
>     with each packet, packet loss can be hidden from the TCP engine d=
ue
>     to lack of dupACKs. This is because the loss is "repaired" by the
>     redundant data in the packet coming after the lost packet. Based =
on
>     incoming ACKs, such hidden loss events are detected, and CWR stat=
e
>     is entered.
>=20
>   o When packets are scheduled for transmission, RDB replaces the SKB=
 to
>     be sent with a modified SKB containing the redundant data of
>     previously sent data segments from the TCP output queue.

Really this looks very complicated.

Why not simply append the new skb content to prior one ?

skb_still_in_host_queue(sk, prior_skb) would also tell you if the skb i=
s
really available (ie its clone not sitting/waiting in a qdisc on the
host)

Note : select_size() always allocate skb with SKB_WITH_OVERHEAD(2048 -
MAX_TCP_HEADER) available bytes in skb->data.

Also note that tcp_collapse_retrans() is very similar to your needs. Yo=
u
might simply expand it.
