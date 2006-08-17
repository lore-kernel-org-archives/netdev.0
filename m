From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Thu, 17 Aug 2006 13:26:35 +0100
Message-ID: <200608171126.k7HBQZ6u031969@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:58565 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S964804AbWHQL1w convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 07:27:52 -0400
Content-Disposition: inline
To: "David Stevens" <dlstevens@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

> Michal,
>         I believe the patch I submitted yesterday fixes this
> problem, and in a simpler way.

Somehow I've missed that e-mail (It did not appear on the thread's list at MARC
archives). Sorry for that.

> 
>                                         +-DLS

I've reviewed your patch (the IPv4 part of it) and I think I can say that
our soulutions are actually quite similar.
But I can come up with one difference that I'd like know your opinion on.

Suppose the following situatuion:

1) create pppX interface:
  IP: A.B.C.D

2) join a multicast group by address: A.B.C.D
  ASSUMPTION: no other interface with the same IP address exists;
  the result should be that the group is joined on the pppX interface

3) create pppY interface
  IP: A.B.C.D (Yes the same IP, not unusual on ppp links.)

4) delete the pppX interace

5) attempt to leave the multicast group by address: A.B.C.D

6) * if your algorthim is used -EADDRNOTAVAIL is returned
   * if mine is used the multicast group is left on the pppX interface

Surely this won't be a common problem but I think it's worth pointing out
here.

Michal
