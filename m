From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net] gro: Make GRO aware of lightweight tunnels.
Date: Wed, 20 Jan 2016 18:52:27 -0800
Message-ID: <CAEh+42j6jcGhtO=sdkacduEB7=JHiqt5PmAq_aintmvQDqj8sw@mail.gmail.com>
References: <1453336048-49406-1-git-send-email-jesse@kernel.org>
 <1453337308.1223.345.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42g+bc-+=qjZ=Ha8580aZf5=o+2CS6pM1m-gKu47sbPTxw@mail.gmail.com> <20160121023159.GD29853@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John <john.phillips5@hpe.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57235 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759360AbcAUCy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 21:54:59 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id B9596205F2
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 02:52:43 +0000 (UTC)
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 71D692015E
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 02:52:42 +0000 (UTC)
Received: by mail-qg0-f44.google.com with SMTP id o11so22308118qge.2
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:52:42 -0800 (PST)
In-Reply-To: <20160121023159.GD29853@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 6:31 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/20/16 at 05:47pm, Jesse Gross wrote:
>> Just to merge the two threads together, all of protocols that would be
>> affected by this also have "normal" GRO handlers that will run when
>> the packet is first received. There's no argument that that is
>> preferable if it is available. However, GRO cells do provide a
>> performance benefit in other situations so it would be nice to avoid
>> disabling it if possible.
>
> I missed this thread when I replied to the other one.
>
> What are these situations? It seems like there are specific
> scenarios where this helps. Is it varying TLVs in the encap header
> for otherwise meregable inner headers?

It's nothing really fancy or tunnel type specific.

It's obviously preferable to merge things as soon as the packet is
received but if we don't (for example, if we don't have a checksum
provided by hardware) then we take another crack at it after
decapsulation. There's still enough stack left after decapsulation for
it to make a difference, particularly if you are going up to a VM. I
guess this shouldn't be surprising because it's basically equivalent
to GRO when there is no tunnel at all.

There was some previous discussion about this a little while ago:
https://www.mail-archive.com/netdev@vger.kernel.org/msg68880.html
