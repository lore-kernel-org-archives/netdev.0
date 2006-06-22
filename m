From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Binding a packet socket to interface down
Date: Thu, 22 Jun 2006 19:51:50 +0400
Message-ID: <20060622155150.GB10335@2ka.mipt.ru>
References: <7e63f56c0606220832i6b00f77bk352482c4a7c638cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:64232 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751619AbWFVPvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 11:51:52 -0400
To: Robert Iakobashvili <coroberti@gmail.com>
Content-Disposition: inline
In-Reply-To: <7e63f56c0606220832i6b00f77bk352482c4a7c638cb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 06:32:29PM +0300, Robert Iakobashvili (coroberti@gmail.com) wrote:
> Hi,
> 
> When packet socket (PF_SOCKET) is attempted in syscall bind () to the
> network interface, which is down (no IF_UPP flag), packet_do_bind ()
> sets error to the socket, but bind () does not fail.
> 
> When datagram, stream or raw socket fail to bind to some local
> ip-port/ip, bind () fails.
> 
> Is this behavior of bind () for packet socket done deliberately, or
> better to correct it so that bind will fail and return errno, e.g. ENODEV?
> Thanks.

man page says that packet socket does not handle any errors.
And actually packet socket binds to the device, but you can not read
data. When device will be turned on, packet socket should start
to function (packet_notifier() -> NETDEV_UP)..


-- 
	Evgeniy Polyakov
