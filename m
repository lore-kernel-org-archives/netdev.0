From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 3/4] ipv4: Namespaceify tcp_fastopen_key knob
Date: Thu, 28 Sep 2017 10:47:54 -0700 (PDT)
Message-ID: <20170928.104754.977799185628171706.davem@davemloft.net>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1506483343-11544-3-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506483343-11544-3-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 27 Sep 2017 11:35:42 +0800

> Different namespace application might require different tcp_fastopen_key
> independently of the host.
> 
> David Miller pointed out there is a leak without releasing the context
> of tcp_fastopen_key during netns teardown. So add the release action in
> exit_batch path.
> 
> Tested:
> 1. Container namespace:
> # cat /proc/sys/net/ipv4/tcp_fastopen_key:
> 2817fff2-f803cf97-eadfd1f3-78c0992b
> 
> cookie key in tcp syn packets:
> Fast Open Cookie
>     Kind: TCP Fast Open Cookie (34)
>     Length: 10
>     Fast Open Cookie: 1e5dd82a8c492ca9
> 
> 2. Host:
> # cat /proc/sys/net/ipv4/tcp_fastopen_key:
> 107d7c5f-68eb2ac7-02fb06e6-ed341702
> 
> cookie key in tcp syn packets:
> Fast Open Cookie
>     Kind: TCP Fast Open Cookie (34)
>     Length: 10
>     Fast Open Cookie: e213c02bf0afbc8a
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
