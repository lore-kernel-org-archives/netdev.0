From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: netfilter: xt_bpf: ABI issue in xt_bpf_info_v1?
Date: Wed, 13 Sep 2017 16:22:13 +0200 (CEST)
Message-ID: <nycvar.YFH.7.76.1709131613520.8761@n3.vanv.qr>
References: <20170913162442.368691c9@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
        Rafael Buchbinder <rbk@nsof.io>, shmulik.ladkani@gmail.com,
        eyal@nsof.io
To: Shmulik Ladkani <shmulik@nsof.io>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170913162442.368691c9@pixies>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2017-09-13 15:24, Shmulik Ladkani wrote:
>
>One way to fix is to have iptables open the object (using the stored
>xt_bpf_info_v1->path), gaining a new process local fd for the object,
>just after getting the rules from IPT_SO_GET_ENTRIES.
>However we didn't see any other extensions doing something like that in
>iptables.
>
>Another way to solve is to fix the ABI (or have a v2 one), that does NOT
>pass the fd from userspace, only the path of the pinned object.
>Then, 'bpf_mt_check_v1' will open the file from the given path in order
>to get the bpf_prog.

But a path has a similar problem like a file descriptor - it is local to a
certain mount namespace.

To load "large" blobs into the kernel, a pointer to user memory is a possible
option. The downside is that such extra data is not retrievable from the kernel
via the iptables setsockopts anymore - one could work around it with procfs, or
just let it be.

https://sourceforge.net/p/xtables-addons/xtables-addons/ci/master/tree/extensions/xt_geoip.c
line 64+.
