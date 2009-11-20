From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Fri, 20 Nov 2009 20:00:07 +0100
Message-ID: <20091120190007.GA2688@ami.dom.local>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
 <20091119095730.GA7661@ff.dom.local>
 <65634d660911200908l5acbf3d0v5fc9a2e1adb7c3a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:43866 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbZKTTAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 14:00:42 -0500
Received: by bwz27 with SMTP id 27so3671223bwz.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 11:00:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <65634d660911200908l5acbf3d0v5fc9a2e1adb7c3a5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 09:08:10AM -0800, Tom Herbert wrote:
> > The description reads: "This solution queues packets early on in th=
e
> > receive path on the backlog queues of other CPUs.", so I'm not sure
> > it's intended.
>=20
> That is precisely the intent.  Getting packets quickly distributed to
> the target cpus maximizes parallelism and reduces latency.

Then precisely the intent is "the backlog queues of target CPUs".
"The backlog queues of other CPUs" may suggest that e.g. one cpu is
only doing distribution etc.

>=20
> Did you test it like this (and it was visibly worse)?:
> >
> > =A0 =A0 =A0 =A0if (cpu < 0 || cpu =3D=3D smp_processor_id())
> >
> >> + =A0 =A0 =A0 =A0 =A0 =A0 return __netif_receive_skb(skb);
> >> + =A0 =A0 else
> >> + =A0 =A0 =A0 =A0 =A0 =A0 return enqueue_to_backlog(skb, cpu);
> >> +}
> >> +
> This increases overall latency due to head of line blocking which wil=
l
> outweigh the benefits of optimizing for this one case.

The way I asked should suggest I "suspected" it's on purpose, and was
curious about "digits", but thanks for confirming this.

Jarek P.
