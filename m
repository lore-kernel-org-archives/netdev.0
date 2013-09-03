From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Tue, 3 Sep 2013 09:18:35 -0300
Message-ID: <CAOMZO5B6_7ADAfGNFgx2MmYDAMQVR6MF_0c-F_LgfQ6sKv1kaA@mail.gmail.com>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:40670 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759923Ab3ICMSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 08:18:36 -0400
Received: by mail-vc0-f176.google.com with SMTP id ha11so3752151vcb.7
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 05:18:35 -0700 (PDT)
In-Reply-To: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 3, 2013 at 8:37 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Allocating skbs when sending out neighbour discovery messages
> currently uses sock_alloc_send_skb() based on a per net namespace
> socket and thus share a socket wmem buffer space.
>
> If a netdevice is temporarily unable to transmit due to carrier
> loss or for other reasons, the queued up ndisc messages will cosnume
> all of the wmem space and will thus prevent from any more skbs to
> be allocated even for netdevices that are able to transmit packets.
>
> The number of neighbour discovery messages sent is very limited,
> use of alloc_skb() bypasses the socket wmem buffer size enforcement
> while the manual call to skb_set_owner_w() maintains the socket
> reference needed for the IPv6 output path.
>
> This patch has orginally been posted by Eric Dumazet in a modified
> form.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Stephen Warren <swarren@wwwdotorg.org>
> Cc: Fabio Estevam <festevam@gmail.com>

I don't get the system hang that I used to see with the previous
version on my ARM board, so

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
