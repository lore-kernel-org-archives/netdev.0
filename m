From: Florian Westphal <fw@strlen.de>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 2 Apr 2017 13:45:45 +0200
Message-ID: <20170402114545.GA31804@breakpoint.cc>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> -	for (i = sizeof(struct tcphdr); i <= tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
> +	for (i = sizeof(struct tcphdr); i < tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
>  		if (opt[i] == TCPOPT_MSS && opt[i+1] == TCPOLEN_MSS) {
>  			u_int16_t oldmss;

maybe I am low on caffeeine but this looks fine, for tcp header with
only tcpmss this boils down to "20 <= 24 - 4" so we acccess offsets 20-23 which seems ok.
