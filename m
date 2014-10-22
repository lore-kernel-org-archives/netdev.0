From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 19:08:03 +0200
Message-ID: <CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<20141022.121418.1477947755244353588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:45195 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbaJVRIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 13:08:05 -0400
Received: by mail-yh0-f43.google.com with SMTP id z6so1803204yhz.16
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 10:08:04 -0700 (PDT)
In-Reply-To: <20141022.121418.1477947755244353588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 22, 2014 at 6:14 PM, David Miller <davem@davemloft.net> wrote:
> Instead, I would expect the device layer to trigger a notification
> during a "technology change" or whatever you want to call losing
> connectivity, whichi TCP can receive and use to start sending zero
> windows over all TCP connections using that path.

I totally agree that this is ideally something that should be
controlled by the device layer. However, these temporary disconnects
are not visible through any normal link events (like link down, loss
of address, ...). The only way to detect the events is to parse meta
data coming from devices and look at traffic statistics. This would
involve for example adding parsing of the different mobile broadband
protocols (QMI, MBIM, and so on) to the device layer. When looking at
for example the commits for the QMI driver, parsing QMI messages seems
to have intentionally been left up to user space applications to avoid
bloating driver.

> And therefore there should be a global option that turns this on for
> the entire system by default.
>
> This requires a lot more work than you have done here, you need to
> add all the notification handling, the logic in TCP to look at the
> attached route on send and trigger zero window probes if the device
> event has happened, etc.

Another approach I designed was to have a separate TCP Freeze module
and trigger the freeze/unfreeze through genetlink-messages. A user
space application will be responsible for monitoring the devices and
decide when to trigger the ZWAs. Would a design like that be
acceptable?

-Kristian
