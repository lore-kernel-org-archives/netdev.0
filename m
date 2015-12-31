From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [net-next] ppp: rtnetlink device handling
Date: Thu, 31 Dec 2015 12:01:40 +0100
Message-ID: <CA+icZUU5z_sgYTOSBGazJU9VSm6qZxfA=PXcRQ5bwj-7rOU6fQ@mail.gmail.com>
References: <CA+icZUVb03kO3O2nqEHazotM_Df4SLUw6SOAuPXuB3eNy_gOHg@mail.gmail.com>
	<20151231104147.GM18510@alphalink.fr>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:33339 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbLaLBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 06:01:41 -0500
Received: by mail-vk0-f43.google.com with SMTP id a188so216329405vkc.0
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2015 03:01:41 -0800 (PST)
In-Reply-To: <20151231104147.GM18510@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 31, 2015 at 11:41 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Thu, Dec 31, 2015 at 08:46:59AM +0100, Sedat Dilek wrote:
>> Hi Guillaume,
>>
>> can you explain why you moved ppp to rtnetlink device handling?
>> Benefits, etc.?
>>
> The objective is to bring all the flexibility of rtnetlink device
> creation to ppp interfaces. This is particularly useful for Network
> Access Servers which need to define device properties at creation
> time. My use case includes setting device name and netns, which is
> impossible with the ioctl-based interface without generating transient
> effects.
>

What do you mean by "my use-case"?
Example?

>> Does anything change when using NetworkManager/ModemManager/pppd for
>> my network setup/handling (here: Ubuntu/precise AMD64)?
>>
> No. The ioctl-based ABI remains unchanged, so programs using it won't
> see any difference. The rtnl ABI only brings a new way to create PPP
> devices.
>
> Whether a ppp device is created with the ioctl or rtnl ABI doesn't
> change its behaviour. In particular ppp devices created with rtnl can
> still be configured with the old ioctls. The only difference I can
> think of, is that managing ppp devices with rtnl allows a user to
> remove it with "ip link del", while this is not possible with ppp
> devices created with ioctl.
>

That all sounds like an improvement.

>> Thanks in advance.
>>
> You're welcome.
>

Building net-next-20151231 with your 3 patches on top...

Guillaume Nault (8):
      ppp: don't set sk_state to PPPOX_ZOMBIE in pppoe_disc_rcv()
      ppp: remove PPPOX_ZOMBIE socket state
      pppox: use standard module auto-loading feature
      ppp: define "ppp" device type
      ppp: declare ppp devices as enumerated interfaces
      ppp: define reusable device creation functions <--- (1)
      ppp: implement rtnetlink device handling <--- (2)
      l2tp: rely on ppp layer for skb scrubbing <--- (3)

...will report.

- Sedat -
