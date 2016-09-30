From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH 2/3] netfilter: hide reference to nf_hooks_ingress
Date: Fri, 30 Sep 2016 13:06:40 -0400
Message-ID: <f7toa35pba7.fsf@redhat.com>
References: <20160930160559.4102745-1-arnd@arndb.de>
        <20160930160559.4102745-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160930160559.4102745-2-arnd@arndb.de> (Arnd Bergmann's message
        of "Fri, 30 Sep 2016 18:05:35 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> A recent cleanup added an unconditional reference to the nf_hooks_ingress pointer,
> but that fails when CONFIG_NETFILTER_INGRESS is disabled and that member is
> not present in net_device:
>
> net/netfilter/core.c: In function 'nf_set_hooks_head':
> net/netfilter/core.c:96:30: error: 'struct net_device' has no member named 'nf_hooks_ingress'
>
> This avoids the build error by simply enclosing the assignment in an #ifdef,
> which may or may not be the correct fix.

NAK, it's not the right fix.  The entry being set may be leaked with only this
hunk.  I've posted a complete fix for this.

Sorry that it was broken.
