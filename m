From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 5/5] netfilter: convert x_tables to use RCU
Date: Fri, 30 Jan 2009 08:05:07 +0100
Message-ID: <4982A6A3.2090304@cosmosbay.com>
References: <20090129062521.092861272@vyatta.com>	<20090129062549.364601936@vyatta.com>	<498235F0.3010806@cosmosbay.com> <20090129151624.37dce05e@extreme> <4982A3D5.3030701@cosmosbay.com> <4982A60F.8020005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57562 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbZA3HFP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 02:05:15 -0500
In-Reply-To: <4982A60F.8020005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
>=20
> Hum, I just checked and indeed there is a problem...
>=20
> #define SUM_COUNTER(s,c)  do { (s).bcnt +=3D (c).bcnt; (s).pcnt +=3D =
(c).pcnt; } while(0)
>=20
> need to be changed to use=20
>=20
> #define SUM_COUNTER(s, c)  do { xt_incr_counter(s, (c).cnt, (c).pcnt)=
;} while (0)
>=20

Oops

#define SUM_COUNTER(s, c)  xt_incr_counter(s, (c).bcnt, (c).pcnt)

