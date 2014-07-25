From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP socket timeout after IP address is removed
Date: Fri, 25 Jul 2014 16:31:35 -0700
Message-ID: <CAK6E8=fydKiyVq5EGYKkQD1gU+OjOs-aJr0S02FLAxan7MPJ1g@mail.gmail.com>
References: <53D2B840.4040308@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Joby Poriyath <joby.poriyath@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:64459 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaGYXcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 19:32:16 -0400
Received: by mail-ig0-f180.google.com with SMTP id l13so1484253iga.7
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 16:32:15 -0700 (PDT)
In-Reply-To: <53D2B840.4040308@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 1:04 PM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> Hi,
>
> We have a timout problem on TCP sockets, which probably has some trivial
> solution, but I couldn't figure it out after hours of staring at the code,
> so hopefully someone can shed some light on it here.
> The scenario is the following:
> - I start an ssh connection from host A to B, it works fine
> - netstat shows the socket is using local address K
> - then I remove local address K, and with DHCP I get a new one, L on a
> different interface (interfaces are always up during the whole time)
> - the socket is still alive, but my SSH connection doesn't transmit
> anything, obviously, as netstat says it is still using IP address K
> - ftrace showed me the data goes through the TCP layer and finally the IP
> layer drops it because the route is no longer valid
>
> On 3.10 kernel it times out after ~15 minutes or so, which isn't too good
> for me. On 2.6.32 it times out after a couple of minutes, and I would like
> to achieve the same, but I couldn't figure out how. Could anyone give me
> some guidance?

Depending on your scenario, you can either try tweaking the sysctl
net.ipv4.tcp_retries2 or use setsockopt TCP_USER_TIMEOUT

man tcp or see http://patchwork.ozlabs.org/patch/62889/


>
> Regards,
>
> Zoltan Kiss
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
