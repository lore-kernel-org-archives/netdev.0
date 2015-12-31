From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [net-next] ppp: rtnetlink device handling
Date: Thu, 31 Dec 2015 11:41:47 +0100
Message-ID: <20151231104147.GM18510@alphalink.fr>
References: <CA+icZUVb03kO3O2nqEHazotM_Df4SLUw6SOAuPXuB3eNy_gOHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55382 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbbLaKlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 05:41:50 -0500
Content-Disposition: inline
In-Reply-To: <CA+icZUVb03kO3O2nqEHazotM_Df4SLUw6SOAuPXuB3eNy_gOHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 31, 2015 at 08:46:59AM +0100, Sedat Dilek wrote:
> Hi Guillaume,
> 
> can you explain why you moved ppp to rtnetlink device handling?
> Benefits, etc.?
> 
The objective is to bring all the flexibility of rtnetlink device
creation to ppp interfaces. This is particularly useful for Network
Access Servers which need to define device properties at creation
time. My use case includes setting device name and netns, which is
impossible with the ioctl-based interface without generating transient
effects.

> Does anything change when using NetworkManager/ModemManager/pppd for
> my network setup/handling (here: Ubuntu/precise AMD64)?
> 
No. The ioctl-based ABI remains unchanged, so programs using it won't
see any difference. The rtnl ABI only brings a new way to create PPP
devices.

Whether a ppp device is created with the ioctl or rtnl ABI doesn't
change its behaviour. In particular ppp devices created with rtnl can
still be configured with the old ioctls. The only difference I can
think of, is that managing ppp devices with rtnl allows a user to
remove it with "ip link del", while this is not possible with ppp
devices created with ioctl.

> Thanks in advance.
> 
You're welcome.

Guillaume
