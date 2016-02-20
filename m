From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv3 net 5/5] nfp: don't trust netif_running() in debug code
Date: Sat, 20 Feb 2016 11:51:35 +0100
Message-ID: <CAJpBn1x0X1GEcwz9P9nMb00mEmUnLajH3Qzb6E6=nCQxGk_G9Q@mail.gmail.com>
References: <1455827893-26366-1-git-send-email-jakub.kicinski@netronome.com>
	<1455827893-26366-6-git-send-email-jakub.kicinski@netronome.com>
	<20160220.000145.1464068847848293405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34295 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993759AbcBTKvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 05:51:36 -0500
Received: by mail-ob0-f177.google.com with SMTP id ts10so13975040obc.1
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 02:51:36 -0800 (PST)
In-Reply-To: <20160220.000145.1464068847848293405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/20/16, David Miller <davem@davemloft.net> wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Thu, 18 Feb 2016 20:38:13 +0000
>
>> Since change_mtu() can fail and leave us with netif_running()
>> returning true even though all rings were freed - we should
>> look at NFP_NET_CFG_CTRL_ENABLE flag to determine if device
>> is really opened.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>
> This is exactly why I don't like how you are doing your MTU change at
> all.
>
> You must not make the device inoperative if you simply cannot perform
> the MTU change.  I'm pretty sure I've told you this already, this
> whole ->close(), MTU change, ->open() OOPS THAT FAILED sequence is a
> non-starter.  You can't do this.

OK, I just wanted as little changes as possbile
here since we are at rc5 already. I should've
really caught that before upstreaming the driver :/

> You are leaving the netdev object in an illegal state when this
> happens.

After the net-next series this could only happen
if FW crashed and stopped responding to
commands. Since this is VF driver I dont see
anything I can do with crashed FW :(  Should I
close the device from the driver side?

Could you please look at the net-next series and
tell me if its a step in the right direction? I feel a
bit puzzled, I thought the next series does
exactly what you wanted.

Thank you for your patience...
