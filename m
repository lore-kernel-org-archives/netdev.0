From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: Consequences of commit 16e5726269611b71c930054ffe9b858c1cea88eb
Date: Fri, 13 Jan 2012 08:20:37 +0100
Message-ID: <CAO+b5-rL5bUmu-eYt5mf66rEHme2gghrd6ZApZPGC3D0shbQbw@mail.gmail.com>
References: <CAO+b5-pGcKbTYQWdWo=kbiQ2ORbgn8GAV_cfYjGzOARmgrsUxQ@mail.gmail.com>
	<1326401943.2617.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric Paris <eparis@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49650 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab2AMHUi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:20:38 -0500
Received: by wibhm14 with SMTP id hm14so132619wib.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:20:37 -0800 (PST)
In-Reply-To: <1326401943.2617.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 9:59 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 12 janvier 2012 =E0 19:14 +0000, Bart Van Assche a =E9crit :
> > If my analysis is correct commit
> > 16e5726269611b71c930054ffe9b858c1cea88eb ("af_unix: dont send
> > SCM_CREDENTIALS by default") changes the value of
> > NETLINK_CREDS(skb)->pid from the sender pid into zero. Does that me=
an
> > that the code using that construct did work in kernel 3.1 but that =
it
> > is broken in kernel 3.2 ? Should that commit be reverted or will
> > someone fix the code that uses NETLINK_CREDS() ? Would changing
> > NETLINK_CREDS(skb)->pid into NETLINK_CB(skb).pid be sufficient ?
> >
> > Thanks,
> >
> > Bart.
> >
> > $ git grep 'NETLINK_CREDS([a-zA-Z0-9_]*)->pid'
> > drivers/scsi/scsi_netlink.c: =A0pid =3D NETLINK_CREDS(skb)->pid;
> > kernel/audit.c: =A0 =A0 =A0 pid =A0=3D NETLINK_CREDS(skb)->pid;
>
> What is your problem exactly ?

While porting some kernel code to 3.2 that communicates with user
space via netlink and that works fine with kernel 3.1 and many
previous kernels I noticed that netlink communication from kernel to
user space was broken with kernel 3.2. I could get that code running
on kernel 3.2 after having reverted commit 16e5726. And with that
commit in place the code also started working if I changed a single
occurrence of NETLINK_CREDS(skb)->pid into NETLINK_CB(skb).pid in the
kernel code that processes received netlink messages.

Bart.
