From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: Default network namespace name
Date: Wed, 21 May 2014 19:51:10 +0300
Message-ID: <CAKoUAr=68yxKqmPx8u9bfE8a-_bnonGZw-FcD=p-bw6=OARZ8A@mail.gmail.com>
References: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Peter Fassberg <pf@leissner.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:43714 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbaEUQvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 12:51:11 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so3633752qgf.7
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 09:51:11 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The default, initial network namespace does not have a name. In fact,
according to the kernel implementation, all namespaces (and in
particular, the network namespace) do not have names. The names of the
network namespaces are created and deleted by the userspace "ip netns"
command.

You can move network interfaces to the initial namespace using pid 1,
for example:

ip netns add myns2
ip link set p4p1 netns myns2

#start bash in myns2
ip nents exec myns2 bash

#move p4p1 from myns2 to the default network namespace

ip link set p4p1 netns 1

Regards,
Rami Rosen

http://ramirose.wix.com/ramirosen


On Wed, May 21, 2014 at 9:36 AM, Peter Fassberg <pf@leissner.se> wrote:
>
> Hi!
>
> Is there a name of the default network namespace?
>
> I would like to execute a command in the default network namespace while
> running a shell in a non-default namespace.
>
> Like this: ip netns exec "" ip link
> Or this:   ip netns exec . ip link
>
> That command end up with a mis-spelled error message: :)
> seting the network namespace "" failed: Invalid argument
>
>
>
> Regards,
>
> Peter
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
