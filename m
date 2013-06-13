From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tun: Add ability to create tun device with
 given index
Date: Thu, 13 Jun 2013 09:52:48 -0700
Message-ID: <20130613095248.68c52109@nehalam.linuxnetplumber.net>
References: <51B99946.3000703@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:44763 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755675Ab3FMQwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 12:52:53 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so6703860pdi.21
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 09:52:53 -0700 (PDT)
In-Reply-To: <51B99946.3000703@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Jun 2013 14:04:54 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Tun devices cannot be created with ifidex user wants, but it's
> required by checkpoint-restore project.
> 
> Long time ago such ability was implemented for rtnl_ops-based
> interface for creating links (9c7dafbf net: Allow to create links
> with given ifindex), but the only API for creating and managing 
> tuntap devices is ioctl-based and is evolving with adding new ones
> (cde8b15f tuntap: add ioctl to attach or detach a file form tuntap
> device).
> 
> Following that trend, here's how a new ioctl that sets the ifindex
> for device, that _will_ be created by TUNSETIFF ioctl looks like.
> So those who want a tuntap device with the ifindex I, should open
> the tun device, call ioctl(fd, TUNSETIFINDEX, I), then call TUNSETIFF.
> If setifindex is not called, then it will be generated as before.
> 
> Is it OK to extend ioctls with this, or should we rather switch the
> whole tuntap driver on full-featured rtln-ops?
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 

I see no check for the most fundamental thing, the ifindex must be unique!
