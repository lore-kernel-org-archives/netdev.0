From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: [PATCH net-next 1/3] net: Flush all skbs related to an
 unregistered device
Date: Thu, 21 May 2015 17:28:47 -0700
Message-ID: <CA+HUmGgqf9CDUx374hSrKVXoYAnc+dNWuh04VTT6m0LcaSuGiQ@mail.gmail.com>
References: <1432077893-4431-1-git-send-email-baptiste@arista.com>
	<1432077893-4431-2-git-send-email-baptiste@arista.com>
	<20150521.170219.1689248066169954260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Baptiste Covolato <baptiste@arista.com>,
	netdev <netdev@vger.kernel.org>, Eric Mowat <mowat@arista.com>,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35841 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbbEVA2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:28:48 -0400
Received: by iepj10 with SMTP id j10so20608797iep.3
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:28:48 -0700 (PDT)
In-Reply-To: <20150521.170219.1689248066169954260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 2:02 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Baptiste Covolato <baptiste@arista.com>
> Date: Tue, 19 May 2015 16:24:51 -0700
>
> > Update flush_backlog to flush all packets in the backlog queue belonging
> > to a device being unregistered. Accordingly on_each_cpu no longer needs
> > to pass a device to flush_backlog since it handles any device in the
> > NETREG_UNREGISTERED state.
> >
> > Signed-off-by: Baptiste Covolato <baptiste@arista.com>
> > Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
>
> This is quite bogus if you ask me.
>
> This is the one spot causing a device to make the transition
> to unregistered state, so passing that specific device to
> flush_backlog() is the completely logical way to handle this.
>
> If this is some hack that is made necessary by your parallel
> notification scheme, I do not find it acceptable.

Using NETREG_UNREGISTERED is not needed in order for the parallel
scheme to work.
One can change flush_backlog to also handle a list of net_devices
instead. In both cases
on_each_cpu is invoked only once instead of once per net_device. In
case of the latter
though more time is spent in flush_backlog, since each packet has to be compared
against all interfaces being deleted.
We tried both approaches and they both worked for us.
Using NETREG_UNREGISTERED can result in a task flushing packets from interfaces
that another task may be in the process of deleting, but that should
not be a problem
since those packets are expected to be flushed anyway and access to
the backlog lists
is protected.

Francesco

>
> I'm not applying this series, sorry.
