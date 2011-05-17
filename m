From: Tom Herbert <therbert@google.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 13:02:25 -0700
Message-ID: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:24877 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200Ab1EQUC2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 16:02:28 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p4HK2ROe029325
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 13:02:27 -0700
Received: from gye5 (gye5.prod.google.com [10.243.50.5])
	by kpbe18.cbf.corp.google.com with ESMTP id p4HK22an014574
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 13:02:25 -0700
Received: by gye5 with SMTP id 5so418854gye.16
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 13:02:25 -0700 (PDT)
In-Reply-To: <20110517.143342.1566027350038182221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I like it!  And this sounds like the sort of algorithm that NICs might
be able to implement to solve the UDP/RSS unpleasantness, so even
better.

Tom

On Tue, May 17, 2011 at 11:33 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> It seems to me that we can solve the UDP fragmentation problem for
> flow steering very simply by creating a (saddr/daddr/IPID) entry in a
> table that maps to the corresponding RPS flow entry.
>
> When we see the initial frag with the UDP header, we create the
> saddr/daddr/IPID mapping, and we tear it down when we hit the
> saddr/daddr/IPID mapping and the packet has the IP_MF bit clear.
>
> We only inspect the saddr/daddr/IPID cache when iph->frag_off is
> non-zero.
>
> It's best effort and should work quite well.
>
> Even a one-behind cache, per-NAPI instance, would do a lot better tha=
n
> what happens at the moment. =A0Especially since the IP fragments most=
ly
> arrive as one packet train.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
