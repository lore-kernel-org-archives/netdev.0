From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add an ability to dump and restore window
 parameters
Date: Thu, 30 Jun 2016 08:16:07 -0400 (EDT)
Message-ID: <20160630.081607.555906539070578914.davem@davemloft.net>
References: <1467066836-3817-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	criu@openvz.org, xemul@parallels.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbcF3MRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 08:17:11 -0400
In-Reply-To: <1467066836-3817-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>
Date: Mon, 27 Jun 2016 15:33:56 -0700

> We found that sometimes a restored tcp socket doesn't work.
> 
> A reason of this bug is incorrect window parameters and in this case
> tcp_acceptable_seq() returns tcp_wnd_end(tp) instead of tp->snd_nxt. The
> other side drops packets with this seq, because seq is less than
> tp->rcv_nxt ( tcp_sequence() ).
> 
> Data from a send queue is sent only if there is enough space in a
> window, so when we restore unacked data, we need to expand a window to
> fit this data.
> 
> This was in a first version of this patch:
> "tcp: extend window to fit all restored unacked data in a send queue"
> 
> Then Alexey recommended me to restore window parameters instead of
> adjusted them according with data in a sent queue. This sounds resonable.
> 
> rcv_wnd has to be restored, because it was reported to another side
> and the offered window is never shrunk.
> One of reasons why we need to restore snd_wnd was described above.
> 
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied to net-next, thanks.
