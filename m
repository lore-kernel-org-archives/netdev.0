From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] bridge: a netlink notification should be sent
 whenever those attributes change
Date: Sat, 5 Mar 2016 22:44:35 +0800
Message-ID: <CADvbK_eiSQFT9uKfJZf_8omcFyiVuh+XbnywzC2wszxqPuThjQ@mail.gmail.com>
References: <2e80304ba6a0021637e362c83f931dc596f72d89.1457007418.git.lucien.xin@gmail.com>
	<56D82E42.4060401@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:34909 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbcCEOog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 09:44:36 -0500
Received: by mail-ob0-f196.google.com with SMTP id qg3so5677109obc.2
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 06:44:35 -0800 (PST)
In-Reply-To: <56D82E42.4060401@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 8:29 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
>
> This is incorrect because you don't have rtnl here, bridge device sysfs
> options take care of rtnl only on per-option basis and they obtain and
> release it themselves, so you won't have rtnl held when you call
> netdev_state_change. While I agree that this is needed, a larger change
> would be necessary for br_sysfs_br.c.
Sorry, I can't follow you, cause I didn't see any held in dev_ioctl, like:
ipip6_tunnel_ioctl
    ipip6_tunnel_update
        netdev_state_change

why sysfs have to hold rtnl ?

> Off-topic: I've been looking into factoring out the bond option API and reusing
> it here as it already has all of this handled, but I won't have time to finish
> it before the next merge window, so if you fix the issue here I'm okay with
> this as interim solution.
>
> Cheers,
>  Nik
>
