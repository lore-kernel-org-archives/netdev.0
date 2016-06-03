From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] soreuseport: add compat case for setsockopt SO_ATTACH_REUSEPORT_CBPF
Date: Sat, 04 Jun 2016 00:20:01 +0200
Message-ID: <57520291.7090004@iogearbox.net>
References: <CAEfhGiwwvwf31Dj+s0zA0bpVAZ4x4=rLuU5g217u=wRrgm07Dg@mail.gmail.com> <20160603214002.GA58242@ast-mbp.thefacebook.com> <20160603214917.GA12557@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Craig Gallek <kraigatgoog@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Helge Deller <deller@gmx.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60883 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbcFCWUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 18:20:09 -0400
In-Reply-To: <20160603214917.GA12557@ls3530.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 11:49 PM, Helge Deller wrote:
> Commit 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> missed to add the compat case for the SO_ATTACH_REUSEPORT_CBPF option.
>
> Signed-off-by: Helge Deller <deller@gmx.de>

LGTM, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

[ Cc Willem: I believe we also need something similar for PACKET_FANOUT_DATA
   when PACKET_FANOUT_CBPF is requested since we have the same issue with the
   pointer in struct sock_fprog there, too. ]

> diff --git a/net/compat.c b/net/compat.c
> index 5cfd26a..1373947 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -354,7 +354,8 @@ static int do_set_sock_timeout(struct socket *sock, int level,
>   static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
>   				char __user *optval, unsigned int optlen)
>   {
> -	if (optname == SO_ATTACH_FILTER)
> +	if (optname == SO_ATTACH_FILTER ||
> +	    optname == SO_ATTACH_REUSEPORT_CBPF)
>   		return do_set_attach_filter(sock, level, optname,
>   					    optval, optlen);
>   	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
>
