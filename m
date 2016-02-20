From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: [PATCH 1/1] net-next: do not store needed_headroom in ip_tunnel_xmit
Date: Sat, 20 Feb 2016 06:55:09 -0800
Message-ID: <CA+HUmGiV3ziOafun_4-wGovB8k5pmefLGbcUHnpvrFMpLStrFA@mail.gmail.com>
References: <1455942374-17650-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Francesco Ruggeri <fruggeri@arista.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34970 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbcBTOzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 09:55:10 -0500
Received: by mail-oi0-f48.google.com with SMTP id x21so30420831oix.2
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 06:55:10 -0800 (PST)
In-Reply-To: <1455942374-17650-1-git-send-email-fruggeri@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 8:26 PM, Francesco Ruggeri <fruggeri@arista.com> wrote:
> Misconfigurations can result in local tunnel loops being created.
> __dev_queue_xmit catches packets caught in a loop and drops them,
> but the affected tunnels' needed_headroom can be corrupted in the
> process as it is recursively updated.

The problem with the patch is that it might force a pskb_expand_head
in the most common cases.
On the other hand if a loop is created then it may not be enough to
undo the configuration and the tunnel device itself should be
reinitialized.
Anybody have a better suggestion?

Thanks,
Francesco
