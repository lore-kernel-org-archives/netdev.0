From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP does not autobind on recv
Date: Mon, 24 Oct 2016 06:03:00 -0700
Message-ID: <1477314180.7065.108.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5d0f78b4-f850-4f73-dbb7-6c3d15d99c86@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ML netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34108 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935271AbcJXNDC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 09:03:02 -0400
Received: by mail-pf0-f181.google.com with SMTP id r16so98754378pfg.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 06:03:02 -0700 (PDT)
In-Reply-To: <5d0f78b4-f850-4f73-dbb7-6c3d15d99c86@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-24 at 14:54 +0200, Jiri Slaby wrote:
> Hello,
> 
> as per man 7 udp:
>   In order to receive packets, the socket can be bound to
>   a local  address first  by using bind(2).  Otherwise,
>   the socket layer will automatically assign a free local
>   port out of the range defined by /proc/sys/net/ipv4
>   /ip_local_port_range and bind the socket to INADDR_ANY.
> 
> I did not know that bind is unneeded, so I tried that. But it does not
> work with this piece of code:
> int main()
> {
>     char buf[128];
>     int fd = socket(AF_INET, SOCK_DGRAM, 0);
>     recv(fd, buf, sizeof(buf), 0);
> }

autobind makes little sense at recv() time really.

How an application could expect to receive a frame to 'some socket'
without even knowing its port ?

How useful would that be exactly ?

How TCP behaves ?

I would say, fix the documentation if it is not correct.
