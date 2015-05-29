From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] tcp: fix child sockets to use system default congestion
 control if not set
Date: Fri, 29 May 2015 20:24:25 +0200
Message-ID: <5568AED9.2030905@iogearbox.net>
References: <1432921627-10515-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53184 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149AbbE2SYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 14:24:31 -0400
In-Reply-To: <1432921627-10515-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 07:47 PM, Neal Cardwell wrote:
> Linux 3.17 and earlier are explicitly engineered so that if the app
> doesn't specifically request a CC module on a listener before the SYN
> arrives, then the child gets the system default CC when the connection
> is established. See tcp_init_congestion_control() in 3.17 or earlier,
> which says "if no choice made yet assign the current value set as
> default". The change ("net: tcp: assign tcp cong_ops when tcp sk is
> created") altered these semantics, so that children got their parent
> listener's congestion control even if the system default had changed
> after the listener was created.
>
> This commit returns to those original semantics from 3.17 and earlier,
> since they are the original semantics from 2007 in 4d4d3d1e8 ("[TCP]:
> Congestion control initialization."), and some Linux congestion
> control workflows depend on that.
>
> In summary, if a listener socket specifically sets TCP_CONGESTION to
> "x", or the route locks the CC module to "x", then the child gets
> "x". Otherwise the child gets current system default from
> net.ipv4.tcp_congestion_control. That's the behavior in 3.17 and
> earlier, and this commit restores that.
>
> Fixes: 55d8694fa82c ("net: tcp: assign tcp cong_ops when tcp sk is created")
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Glenn Judd <glenn.judd@morganstanley.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Ok, change looks good to me, thanks.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
