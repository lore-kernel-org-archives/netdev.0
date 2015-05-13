From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: netns: use a spin_lock to protect nsid management
Date: Wed, 13 May 2015 13:58:25 +0200
Message-ID: <55533C61.2030206@6wind.com>
References: <20150512175227.GA19020@mwanda> <CAM_iQpUSgpeL_Dy+U+KrBd=h3bhm03vASupdO-9dSs+CKYjNeg@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34386 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbbEML62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:58:28 -0400
Received: by wgic8 with SMTP id c8so40950616wgi.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 04:58:27 -0700 (PDT)
In-Reply-To: <CAM_iQpUSgpeL_Dy+U+KrBd=h3bhm03vASupdO-9dSs+CKYjNeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/05/2015 21:16, Cong Wang a =C3=A9crit :
[snip]
> Also why do we have to disable IRQ when holding the spinlock?
> IOW, which case takes the spin lock in IRQ context?
peernet2id() is called by do_one_broadcast() (net/netlink/af_netlink.c)=
=2E So
every callers of netlink_broadcast[_filtered]()/nlmsg_unicast()
/nlmsg_multicast() may needs this lock.
