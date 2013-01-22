From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: add ability to set a timestamp offset
Date: Tue, 22 Jan 2013 16:18:04 -0500
Message-ID: <CADVnQynxigC7wSW6D1WQNZwxoBd7fpySa8eGN0W4wrh7WtHV4Q@mail.gmail.com>
References: <1358887953-28665-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Netdev <netdev@vger.kernel.org>, criu@openvz.org,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:35439 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181Ab3AVVSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:18:06 -0500
Received: by mail-ee0-f44.google.com with SMTP id l10so3783648eei.3
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 13:18:04 -0800 (PST)
In-Reply-To: <1358887953-28665-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 3:52 PM, Andrey Vagin <avagin@openvz.org> wrote:
> If a TCP socket will get live-migrated from one box to another the
> timestamps (which are typically ON) will get screwed up -- the new
> kernel will generate TS values that has nothing to do with what they
> were on dump. The solution is to yet again fix the kernel and put a
> "timestamp offset" on a socket.

One serious issue with this patch is that outgoing timestamp values
will no longer correspond to tcp_time_stamp, so echoed timestamp
values will also no longer have a meaningful relationship to
tcp_time_stamp. That violates assumptions made in several places in
the code, which assumes that we can compare echoed timestamp values to
tcp_time_stamp; for example, there are several places where we do
things like subtracting:
   tcp_time_stamp - tp->rx_opt.rcv_tsecr
to find the estimated RTT for a segment.

neal
