From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] geneve: fix max_mtu setting
Date: Mon, 27 Jun 2016 09:13:37 +0800
Message-ID: <E2E0946D-26C9-46E9-B01A-94595D9EEAF7@cmss.chinamobile.com>
References: <1466915256-98925-1-git-send-email-yanhaishuang@cmss.chinamobile.com> <CAD=hENenX+VThWkgWeqOw=kHoa2n5PePBO=WwR5uFFidAmWzfQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD=hENenX+VThWkgWeqOw=kHoa2n5PePBO=WwR5uFFidAmWzfQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Jun 26, 2016, at 8:35 PM, zhuyj <zyjzyj2000@gmail.com> wrote:
> 
> +       if (geneve->remote.sa.sa_family == AF_INET)
> +               max_mtu -= sizeof(struct iphdr);
> +       else
> +               max_mtu -= sizeof(struct ipv6hdr);
> 
> Sorry, if sa_family is not AF_NET, it is AF_INET6?
> 
> There is a lot of macros in include/linux/socket.h.
> 
> Zhu Yanjun
> 

There are only two enumerations AF_INET and AF_INET6 have been assigned in geneve_newlink:

        if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
                return -EINVAL;

        if (data[IFLA_GENEVE_REMOTE]) {
                remote.sa.sa_family = AF_INET;
                remote.sin.sin_addr.s_addr =
                        nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
        }

        if (data[IFLA_GENEVE_REMOTE6]) {
                if (!IS_ENABLED(CONFIG_IPV6))
                        return -EPFNOSUPPORT;

                remote.sa.sa_family = AF_INET6;
                remote.sin6.sin6_addr =
                        nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);

                if (ipv6_addr_type(&remote.sin6.sin6_addr) &
                    IPV6_ADDR_LINKLOCAL) {
                        netdev_dbg(dev, "link-local remote is unsupported\n");
                        return -EINVAL;
                }
        }

So I think the else case is for AF_INET6 only.
