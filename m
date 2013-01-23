From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/2] tcp: add ability to set a timestamp offset (v2)
Date: Wed, 23 Jan 2013 19:26:41 +0400
Message-ID: <51000131.3070300@parallels.com>
References: <1358953314-12979-1-git-send-email-avagin@openvz.org> <1358953314-12979-3-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358953314-12979-3-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 086ceda..23f93d4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2704,6 +2704,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  		else
>  			err = -EINVAL;
>  		break;
> +	case TCP_TIMESTAMP:
> +		tp->tsoffset = 0;
> +		tp->tsoffset = val - tcp_time_stamp(tp);

I believe we should check that the socket state is TCP_CLOSE.
Otherwise tcp_time_stamp() readers might be surprised while
reading the value.

> +		break;
>  	default:
>  		err = -ENOPROTOOPT;
>  		break;
