From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Mon, 31 Oct 2011 22:02:19 +0200
Message-ID: <CAEnQRZAGc42q1LCEDs=QigLkXeHBui=KnAm5=5xrEzvA-LDcGg@mail.gmail.com>
References: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com>
	<20111028.183107.2091450715774357523.davem@davemloft.net>
	<4EAB2F58.7080509@hp.com>
	<20111028.222430.1568567893138453593.davem@davemloft.net>
	<CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com>
	<4EAEE487.5080905@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, luto@amacapital.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:54326 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933834Ab1JaUCU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 16:02:20 -0400
Received: by qyk27 with SMTP id 27so6667751qyk.19
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 13:02:19 -0700 (PDT)
In-Reply-To: <4EAEE487.5080905@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2011 at 8:10 PM, Rick Jones <rick.jones2@hp.com> wrote:
> Whether tracked as bytes or segments, my take is that to ask applicat=
ions to
> have to think about another non-portable socket option is ungood. =A0=
I would
> suggest taking the time to work-out the automagic heuristic to drop t=
he
> deferred ACK count on connections where it being large is un-desirabl=
e and
> then not need to worry about the limits being global.

Your suggestion deserves further investigation, it looks tricky to
find a good heuristic for increasing/decreasing the ACK deferred count.

>
> Given the stack's existing propensity to try to decide when to increa=
se the
> window I might even go so far as to suggest the sense of the heuristi=
c be
> flipped and it seek to decide when it is ok to increase the number of
> segments/bytes per ACK. =A0To what extent one needs to go beyond what=
 happens
> already with the stretching of ACKs via GRO/LRO or if that mechanism =
can
> serve as part of the logic of the heuristic is probably a fertile are=
a for
> discussion.
>
> If I recall correctly, in one of your earlier posts you mentioned som=
ething
> about a 20% performance boost. =A0What were the specific conditions o=
f that
> testing? =A0Was it over a setup where the receiver already had LRO/GR=
O or was
> it over a more plain receiver NIC without that functionality?

If I remember correctly on the receiver side there was no LRO/GRO, but =
we
tweaked some of /proc/sys/net/ipv4 parameters (e.g tcp_rmem).
Also, the traffic was highly unidirectional with many clients feeding m=
ultimedia
content to a server.

Anyhow, we used our custom kernel which is an older kernel version.
Are there any recommended benchmarks/tools for testing this kind of par=
ameters?

Daniel.
