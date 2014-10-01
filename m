From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_core: Disable BF when write
 combining is not available
Date: Wed, 1 Oct 2014 09:52:05 -0700
Message-ID: <CAADnVQJ7uGj1TjV=Bv107TEWmVRodnff1sKFROEdpZJrZ5+R4w@mail.gmail.com>
References: <1412175282-25212-1-git-send-email-ogerlitz@mellanox.com>
	<1412175282-25212-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moshe Lazer <moshel@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:52146 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbaJAQwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 12:52:06 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so588774qgf.21
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 09:52:05 -0700 (PDT)
In-Reply-To: <1412175282-25212-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 7:54 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> From: Moshe Lazer <moshel@mellanox.com>
>
> In mlx4 for better latency, we write send descriptors to a write-combining
> (WC) mapped buffer instead of ringing a doorbell and having the HW fetch
> the descriptor from system memory.
>
> However, if write-combining is not supported on the host, then we
> obtain better latency by using the doorbell-ring/HW fetch mechanism.
>
> The mechanism that uses WC is called Blue-Flame (BF). BF is beneficial
> only when the system supports write combining. When the BF buffer is
> mapped as a write-combine buffer, the HCA receives data in multi-word
> bursts. However, if the BF buffer is mapped only as non-cached, the
> HCA receives data in individual dword chunks, which harms performance.
>
> Therefore, disable blueflame when write combining is not available.

curious, what numbers you're seeing:
- bf=on with wc
- bf=on without wc
- bf=off and doorbell
they will help to justify this change.
