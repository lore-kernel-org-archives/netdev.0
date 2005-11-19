From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG INFO]IPv6: sleeping function called from invalid context.
Date: Sat, 19 Nov 2005 22:48:15 +1100
Message-ID: <E1EdRCZ-0007uy-00@gondolin.me.apana.org.au>
References: <20051118123557.GD20395@postel.suug.ch>
Cc: yoshfuji@linux-ipv6.org, yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751187AbVKSLss@vger.kernel.org>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20051118123557.GD20395@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> 
> I did. I think it was right, why would an allocation be necessary on
> the second call to inet6_dump_fib()? The walker allocated in process
> context on the first call should be reused from cb->args[0].

Continued dumps are always called under spin lock (see netlink_dump).
So we need to use GFP_ATOMIC in dumpers.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
