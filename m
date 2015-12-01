From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] bridge: Only call /sbin/bridge-stp for the initial
 network namespace
Date: Tue, 01 Dec 2015 15:13:44 +0100
Message-ID: <1448979224.3359384.454695137.2DC07EE8@webmail.messagingengine.com>
References: <565B7F7D.80208@nod.at>
 <CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
 <87egf7183c.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
	bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kees Cook <keescook@chromium.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:35869 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755852AbbLAONo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:13:44 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 493F920D15
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 09:13:44 -0500 (EST)
In-Reply-To: <87egf7183c.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015, at 22:38, Eric W. Biederman wrote:
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/bridge/br_stp_if.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 5396ff08af32..742fa89528ab 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -142,7 +142,9 @@ static void br_stp_start(struct net_bridge *br)
>  	char *envp[] = { NULL };
>  	struct net_bridge_port *p;
>  
> -       r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
> +       r = -ENOENT;
> +       if (dev_net(br->dev) == &init_net)

net_eq ?

> +               r = call_usermodehelper(BR_STP_PROG, argv, envp,
> UMH_WAIT_PROC);
>  
>  	spin_lock_bh(&br->lock);
>  

Otherwise, ack, so far.

As our /sys interfaces directories are tagged by the net namespace it
would actually make sense to run bridge-stp automatically in another
name space.

Bye,
Hannes
