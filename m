From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Thu, 08 Dec 2016 22:03:44 +0100
Message-ID: <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:42620 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752872AbcLHVEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:04:05 -0500
In-Reply-To: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tom,

On Wed, Dec 7, 2016, at 00:06, Tom Herbert wrote:
> We are seeing a fair number of machines getting into softlockup in 4.6
> kernel. As near as I can tell this is happening on the spinlock in
> bind hash bucket. When inet_csk_get_port exits and does spinunlock_bh
> the TCP timer runs and we hit lockup in inet_put_port (presumably on
> same lock). It seems like the locked isn't properly be unlocked
> somewhere but I don't readily see it.
> 
> Any ideas?

Likewise we received reports that pretty much look the same on our
heavily patched kernel. Did you have a chance to investigate or
reproduce the problem?

I am wondering if you would be able to take a complete thread stack dump
if you can reproduce this to check if one of the user space processes is
looping inside finding a free port?

Thanks,
Hannes
