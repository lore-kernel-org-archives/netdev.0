From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 23:03:10 +0800
Message-ID: <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
References: <1336744796.31653.164.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:40709 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760183Ab2EKPDb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 11:03:31 -0400
Received: by qcro28 with SMTP id o28so2037390qcr.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 08:03:30 -0700 (PDT)
In-Reply-To: <1336744796.31653.164.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 11, 2012 at 9:59 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Fair Queue Codel implementation.
>
> Principles :
>
> - Packets are classified (internal classifier or external) on flows.
> - This is a Stochastic model (as we use a hash, several flows might
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0be hashed =
on same slot)
> - Each flow has a CoDel managed queue.
> - Flows are linked onto two (Round Robin) lists,
> =A0so that new flows have priority on old ones.

I don't think it is a good idea, as the old ones may be starved. It isn=
't
fair. Why not use the conventional DRR?

> +
> + =A0 =A0 =A0 /* Queue is full! Find the fat flow and drop packet fro=
m it.
> + =A0 =A0 =A0 =A0* This might sound expensive, but with 1024 flows, w=
e scan
> + =A0 =A0 =A0 =A0* 4KB of memory, and we dont need to handle a comple=
x tree
> + =A0 =A0 =A0 =A0* in fast path (packet queue/enqueue) with many cach=
e misses.
> + =A0 =A0 =A0 =A0*/

How about the tricks used by SFQ?

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
