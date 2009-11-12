From: Changli Gao <xiaosuo@gmail.com>
Subject: [RACE] net: in process_backlog
Date: Thu, 12 Nov 2009 16:50:53 +0800
Message-ID: <412e6f7f0911120050w740377c7j2cdf24ef9fd2ca59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:35878 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbZKLIus convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 03:50:48 -0500
Received: by pwi3 with SMTP id 3so1223769pwi.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 00:50:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Stephen:

I don't think this change
http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3Dcom=
mitdiff;h=3D6e583ce5242f32e925dcb198f7123256d0798370
is correct.

                        local_irq_enable();
                        break;
                }
-
                local_irq_enable();

-               dev =3D skb->dev;
-
on MP system, flush_backlog() will be called here, and after that
skb->dev will be invalid, if we access it, sth. unexpected may
happens.

                netif_receive_skb(skb);
-
-               dev_put(dev);
        } while (++work < quota && jiffies =3D=3D start_time);

        return work;

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
