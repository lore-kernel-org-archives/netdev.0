From: kuznet@ms2.inr.ac.ru
Subject: Re: IFF_NOARP & broadcasting [2]
Date: Thu, 25 Jul 2002 18:02:18 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207251402.SAA02033@sex.inr.ac.ru>
References: <20020725163223.A13299@karlis>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: karlis@mt.lv (Karlis Peisenieks)
In-Reply-To: <20020725163223.A13299@karlis> from "Karlis Peisenieks" at Jul 25, 2 04:32:23 pm
List-Id: netdev.vger.kernel.org

Hello!

> Ok, but even in this case there is minor problem. And it lies in
> net/ethernet/eth.c - eth_header.

You have just made great discovery. :-)

It was big puzzle why people blame that they see packets with zero MAC,
sometimes. Apparently, this happens on the first packet, when hh cache
is still not created. :-)


> Please comment on this patch :) :

I am not sure that this is right. Protocols using neighbour cache
will work, but anothers will fail on NOARP devices.

It is safer just to reorder two ifs, checking for daddr!=NULL first.

Alexey
