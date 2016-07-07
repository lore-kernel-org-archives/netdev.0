From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] vxlan: remove gro_cell support
Date: Thu, 07 Jul 2016 18:13:22 +0200
Message-ID: <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1467907022.git.pabeni@redhat.com>
	 <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:33289 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbcGGQN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 12:13:27 -0400
Received: by mail-yw0-f182.google.com with SMTP id j17so18416676ywg.0
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 09:13:27 -0700 (PDT)
In-Reply-To: <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 17:58 +0200, Paolo Abeni wrote:
> GRO is now handled entirely by the udp_offload layer and  there is no need
> for trying it again at the device level. We can drop gro_cell usage,
> simplifying the driver a bit, while maintaining the same performance for
> TCP and improving slightly for UDP.
> This basically reverts the commit 58ce31cca1ff ("vxlan: GRO support
> at tunnel layer")

Note that gro_cells provide GRO support after RPS, so this helps when we
must perform TCP checksum computation, if NIC lacks CHECKSUM_COMPLETE

(Say we receive packets all steered to a single RX queue due to RSS hash
being computed on outer header only)

Some people disable GRO on the physical device, but enable GRO on the
tunnels.
