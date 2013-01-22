From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add ability to set a timestamp offset
Date: Tue, 22 Jan 2013 16:24:10 -0500 (EST)
Message-ID: <20130122.162410.201366520574331812.davem@davemloft.net>
References: <1358887953-28665-1-git-send-email-avagin@openvz.org>
	<CADVnQynxigC7wSW6D1WQNZwxoBd7fpySa8eGN0W4wrh7WtHV4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	edumazet@google.com, ycheng@google.com, xemul@parallels.com,
	davej@redhat.com, mtk.manpages@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab3AVVYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:24:15 -0500
In-Reply-To: <CADVnQynxigC7wSW6D1WQNZwxoBd7fpySa8eGN0W4wrh7WtHV4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 22 Jan 2013 16:18:04 -0500

> On Tue, Jan 22, 2013 at 3:52 PM, Andrey Vagin <avagin@openvz.org> wrote:
>> If a TCP socket will get live-migrated from one box to another the
>> timestamps (which are typically ON) will get screwed up -- the new
>> kernel will generate TS values that has nothing to do with what they
>> were on dump. The solution is to yet again fix the kernel and put a
>> "timestamp offset" on a socket.
> 
> One serious issue with this patch is that outgoing timestamp values
> will no longer correspond to tcp_time_stamp, so echoed timestamp
> values will also no longer have a meaningful relationship to
> tcp_time_stamp. That violates assumptions made in several places in
> the code, which assumes that we can compare echoed timestamp values to
> tcp_time_stamp; for example, there are several places where we do
> things like subtracting:
>    tcp_time_stamp - tp->rx_opt.rcv_tsecr
> to find the estimated RTT for a segment.

Right, this change seems pretty bogus as-is.
