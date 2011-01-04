From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: Re: 'tcp: bind() fix when many ports are bound' problem
Date: Tue, 4 Jan 2011 13:12:09 +0400
Message-ID: <AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
References: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"eric.dumazet" <eric.dumazet@gmail.com>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53028 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1ADJMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 04:12:10 -0500
Received: by qwa26 with SMTP id 26so14264491qwa.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 01:12:09 -0800 (PST)
In-Reply-To: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there!

Well, that looks strange.

On my own side I've just put workaround (manually binding to all ports
in sequence :)
and moved production code to FreeBSD as it has better scalable network stack.

I can see the potential problem with that bind() problem on highly
loaded DNS servers/resolvers which establish tons of outgoing UDP
connections.

In some cases that connections could fail and as not receiving the
answer it is normal condition for DNS this will go totally unnoticed.

I don't think anyone will hit this bug in production environment
except the very high load applications.

/Gaspar

2011/1/4 Daniel Baluta <daniel.baluta@gmail.com>:
> Hi,
>
> After a series of discussions [1], Eric provided
> "tcp: bind() fix when many ports are bound" patch. ([2])
>
> Anyhow, due to this problem ([3]) it was reverted.
> Where there any follow ups on this patch?
>
> I have spent some time looking at inet_csk_get_port with the
> only conclusion that it's scary :D.
>
> Should I work around patch "tcp: bind() fix when many ports are bound",
> and try to fix problem [3], or is that a dead end?
>
> thanks,
> Daniel.
>
> [1] http://kerneltrap.org/mailarchive/linux-netdev/2010/4/20/6275120
> [2] http://kerneltrap.org/mailarchive/git-commits-head/2010/4/24/32191
> [3] http://kerneltrap.org/mailarchive/linux-kernel/2010/4/28/4563937
>



-- 
Gaspar Chilingarov

tel +37493 419763 (mobile - leave voice mail message)
icq 63174784
skype://gasparch
e mailto:nm@web.am mailto:gasparch@gmail.com
w http://gasparchilingarov.com/
