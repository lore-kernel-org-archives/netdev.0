From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Wed, 5 Jul 2017 16:01:55 -0700
Message-ID: <CAF2d9jjsRXnuPz3WKSRZK5ctj_c2BMBcWfiWbe4vxesGA8fNgg@mail.gmail.com>
References: <20170704191615.6412-1-mahesh@bandewar.net> <20170705.092032.1482668095877350196.davem@davemloft.net>
 <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
 <20170705.170524.241248681076978527.davem@davemloft.net> <CAF2d9jhTujK0J53DODxCp+0yYnR2RTz7rVGaJE=xeN0-9k4C3g@mail.gmail.com>
 <871spuek9i.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: mahesh@bandewar.net, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36271 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752466AbdGEXCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 19:02:17 -0400
Received: by mail-it0-f46.google.com with SMTP id m68so126262655ith.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 16:02:17 -0700 (PDT)
In-Reply-To: <871spuek9i.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I wonder if it is too late to change this since this behavior is probably
> from the beginning of network namespace. A networkless netns is also
> useful at least for testing purpose, we do use it as a sandbox.
>
Sandbox is my use case too but i'm worried about all other things that
a process inside that namespace can do (tasks' capability mask) and
want to eliminate a need to have a capability just to bing-up the
loopback device (more in the commit message update)


> If you can please include the analysis that describes why no one will
> care. Especially applications such as vsftpd that create network
> namespaces as a way to sandbox themselves and not have a network stack
> available.
>
Well, I wasn't sure hence probed with the RFC patch.
I'm not familiar with the vsftpd use-case but I assume it's expecting
a loopback device to be in DOWN state.

Now that you have made me aware of some use cases that do want the
loopback device to be DOWN, could we use a global sysctl to dictate
the loopback behavior during init? e.g.

net.core.netdev_loopback_state = {0|1}

    where 0: is current behavior i.e. DOWN by default.
               1: is the proposed new behavior i.e. UP by default.

We can keep the default value of this sysctl to be '1' so that when a
host boots, the loopback is UP by default.
 In a running system that prefers the loopback device to come up in
DOWN state for the namespaces, can change the value of this sysctl to
'0' so every namespace creation will come-up with loopback in DOWN
state. Or we could reverse the behavior by changing the default value
of this sysctl (to '0').

Thanks,
--mahesh..
