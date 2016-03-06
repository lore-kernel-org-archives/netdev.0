From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] bridge: a netlink notification should be sent
 whenever those attributes change
Date: Sun, 6 Mar 2016 14:08:49 +0800
Message-ID: <CADvbK_czyyD2G5FimeBrS=WQ80BEeJb8_rVgkLD5wQErwJMhxQ@mail.gmail.com>
References: <2e80304ba6a0021637e362c83f931dc596f72d89.1457007418.git.lucien.xin@gmail.com>
	<56D82E42.4060401@cumulusnetworks.com>
	<CADvbK_eiSQFT9uKfJZf_8omcFyiVuh+XbnywzC2wszxqPuThjQ@mail.gmail.com>
	<56DB36CB.2010407@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:34386 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbcCFGIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 01:08:50 -0500
Received: by mail-ob0-f193.google.com with SMTP id wz1so6467096obc.1
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 22:08:50 -0800 (PST)
In-Reply-To: <56DB36CB.2010407@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 6, 2016 at 3:43 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 03/05/2016 03:44 PM, Xin Long wrote:
>
> See the comment above dev_ifsioc:
> /*
>  *      Perform the SIOCxIFxxx calls, inside rtnl_lock()
>  */
> static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
> {
> ...
> it is usually called like:
>                        rtnl_lock();
>                        ret = dev_ifsioc(net, &ifr, cmd);
>                        rtnl_unlock();
> And also you cannot be calling netdevice notifiers without RTNL. So in any
> case you do need it here as well, in fact you'll surely hit the ASSERT_RTNL();
> in call_netdevice_notifiers_info if you do so, thus I'm not sure how this
> patch was actually tested.
>
yes, I can see it now.
I will repost this patch with rtnl_lock in br_sysfs_*.
Thanks Nik.

>
