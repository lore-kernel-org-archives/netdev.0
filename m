From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH NEXT 3/5] qlcnic: vlan lro support
Date: Fri, 17 Sep 2010 10:28:26 +0200
Message-ID: <1284712107.3391.32.camel@edumazet-laptop>
References: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
	 <1284642872-27832-4-git-send-email-amit.salecha@qlogic.com>
	 <1284643638.3352.30.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F8005A@MNEXMB2.qlogic.org>
	 <381611284708887@web110.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amit Salecha <amit.salecha@qlogic.com>, netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f47.google.com ([74.125.82.47]:36715 "EHLO
	mail-ww0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab0IQIeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 04:34:07 -0400
Received: by wwf26 with SMTP id 26so1037459wwf.4
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 01:34:05 -0700 (PDT)
In-Reply-To: <381611284708887@web110.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 septembre 2010 =C3=A0 11:34 +0400, "Oleg A. Arkhangelsky=
" a
=C3=A9crit :
>=20
> 17.09.2010, 11:10, "Amit Salecha" <amit.salecha@qlogic.com>:
> >>  -----Original Message-----
> >>  From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >>  Sent: Thursday, September 16, 2010 6:57 PM
> >>  To: Amit Salecha
> >>  Cc: davem@davemloft.net; netdev@vger.kernel.org; Ameen Rahman; An=
irban
> >>  Chakraborty
> >>  Subject: Re: [PATCH NEXT 3/5] qlcnic: vlan lro support
> >>
> >>  Le jeudi 16 septembre 2010 =C3=A0 06:14 -0700, Amit Kumar Salecha=
 a =C3=A9crit :
> >>>  LRO + GRO + vlan rx accleration support, performance increases
> >>>  around 20% and cpu utilization reduces around 70% on vlan interf=
ace.
> >>  Interesting. What is the workload that demonstrates such gains ?
> >
> > Just to demonstrate decrease in cpu utilization further:
> > I have taken numbers with various load. I used iperf application to=
 run tcp traffic on vlan interface.
>=20
> > There is around 80-90% of reduction in cpu utilization.
>=20
> I'm wondering, how can this scale further. For example if I have 200K=
 low speed simultaneous
> TCP connections (router appliance case with many users). Can GRO give=
 us some gain here?
>=20

I dont think it can help in a mixed trafic:

GRO in itself has an overhead and cannot handle more than 8 different
sessions per NAPI run.

UDP frames hit the overhead but not the GRO gain.

Because most tcp sessions are short lived and initcwnd is small, most
frames wont be coalesced.



