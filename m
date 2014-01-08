From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: add skb_checksum_setup
Date: Wed, 08 Jan 2014 14:43:04 -0800
Message-ID: <1389220984.31367.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389189511-14568-1-git-send-email-paul.durrant@citrix.com>
	 <1389189511-14568-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33428 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757266AbaAHWmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 17:42:55 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so2472763pad.10
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 14:42:55 -0800 (PST)
In-Reply-To: <1389189511-14568-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 13:58 +0000, Paul Durrant wrote:
> This patch adds a function to set up the partial checksum offset for IP
> packets (and optionally re-calculate the pseudo-header checksum) into the
> core network code.
> The implementation was previously private and duplicated between xen-netback
> and xen-netfront, however it is not xen-specific and is potentially useful
> to any network driver.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/linux/netdevice.h |    1 +
>  net/core/dev.c            |  271 +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 272 insertions(+)

Is there any reason to put this in net/core/dev.c instead of
net/core/skbuff.c ?


Also, no inline should be used in a .c file

( skb_maybe_pull_tail )
