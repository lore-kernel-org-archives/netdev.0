From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What's the right way to use a *large* number of source
 addresses?
Date: Fri, 23 May 2014 07:14:18 -0700
Message-ID: <1400854458.5367.200.camel@edumazet-glaptop2.roam.corp.google.com>
References: <6zlhtsvnqp.fsf@southpole.se>
	 <CACP96tQMEQcTPZaCT7mehis-H5Sw_-74F6fSvZxB7Lr3Hqo0kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35176 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaEWOOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 10:14:20 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so4168529pbc.26
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 07:14:20 -0700 (PDT)
In-Reply-To: <CACP96tQMEQcTPZaCT7mehis-H5Sw_-74F6fSvZxB7Lr3Hqo0kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-23 at 08:53 -0400, sowmini varadhan wrote:

> I think the issue here is the netlink API: if you try to do the same thing
> with ifconfig (instead of /sbin/ip), you'll find things are much faster,
> which seems paradoxical because ip(7) and netlink sockets are the
> recommended config paths. When I ran into this, it turned out that the
> difference was due to the implementation- the ioctl path was able to
> use the ifr_name efficiently to identify the target interface, unlike
> the netlink config path.

Only if you launch on "ip" command for one IP address it might be slow.

ip populates a cache at startup.

Use the batch mode, and it will be much faster than ifconfig, as
ifconfig does not support this mode (you need one fork()/exec() per IP
address)

ip -batch filename
