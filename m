From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH] Packet mmap : allow the user to choose the offset of the
 tx payload.
Date: Fri, 5 Oct 2012 16:17:12 +0200
Message-ID: <CAD6jFUTmNiRHdAkckkwcV2rEOf_kxjHmntTO+rG6ewLs-RhFfg@mail.gmail.com>
References: <1349442629-10960-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, edumazet@google.com, xemul@parallels.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net, uaca@alumni.uv.es
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37083 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012Ab2JEORY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 10:17:24 -0400
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TK8iN-0006CU-1j
	for netdev@vger.kernel.org; Fri, 05 Oct 2012 16:17:23 +0200
Received: from [209.85.212.172] (helo=mail-wi0-f172.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TK8ed-0002oU-PN
	for netdev@vger.kernel.org; Fri, 05 Oct 2012 16:13:27 +0200
Received: by mail-wi0-f172.google.com with SMTP id hq12so802458wib.1
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 07:17:12 -0700 (PDT)
In-Reply-To: <1349442629-10960-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 5, 2012 at 3:10 PM, Paul Chavent <Paul.Chavent@onera.fr> wrote:
> The tx offset of packet mmap tx ring used to be :
> (TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))
>
> The problem is that depending on the usage of SOCK_DGRAM or
> SOCK_RAW, the payload could be aligned or not.
>
> This patch allow to let the user give an offset for it's tx
> payload if he desires.
>
> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>

Can you provide an example when it doesn't hit TPACKET_ALIGNMENT?

On the first look, could it be that your patch currently enforces the
use of your tp_net's offset for *all* TX_RING users, even if they
don't care about it? So in case off==0, you probably get a negative
offset in case of SOCK_RAW, thus it won't hit the second if-statement.
Sure, but this does not look intuitive in my opinion. Maybe, it's
better to only enter this path if the offset *is* used by someone.

Also, to my knowledge tp_net is currently only applied in receive
path. So, if for whatever reason people did not explicitly set tp_net
to 0, it might break their code, if there's a random offset in it,
right?

Best,
Daniel
