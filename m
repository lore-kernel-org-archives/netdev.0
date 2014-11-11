From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Tue, 11 Nov 2014 15:12:27 -0800
Message-ID: <CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34309 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaKKXM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:12:28 -0500
Received: by mail-qg0-f46.google.com with SMTP id i50so7902680qgf.33
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 15:12:28 -0800 (PST)
In-Reply-To: <1415744984-25802-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 2:29 PM, Mahesh Bandewar <maheshb@google.com> wrote:
> This driver is very similar to the macvlan driver except that it
> uses L3 on the frame to determine the logical interface while
> functioning as packet dispatcher. It inherits L2 of the master
> device hence the packets on wire will have the same L2 for all
> the packets originating from all virtual devices off of the same
> master device.

Why do we need this from the beginning?
IOW, what problem does this solve while macvlan doesn't?


>
> This driver was developed keeping the namespace use-case in
> mind. Hence most of the examples given here take that as the
> base setup where main-device belongs to the default-ns and
> virtual devices are assigned to the additional namespaces.
>

Which virtual device is still not aware of netns now? I'd be surprised.

I _guess_ you mean the if_link of macvlan, that is unfortunately
not just macvlan, but because of netns isolates from L2, it is purely
a display problem, macvlan should work well, just its netlink dump
is confusing.
