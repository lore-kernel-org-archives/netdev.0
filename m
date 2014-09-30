From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix nf_conn_nat->masq_index visibility
Date: Tue, 30 Sep 2014 13:47:16 +0200
Message-ID: <20140930114716.GA21568@salvia>
References: <2670668.vq09CjLWH3@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2670668.vq09CjLWH3@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 01:27:50PM +0200, Arnd Bergmann wrote:
> A recent change introduced the NF_NAT_MASQUERADE_IPV4/6 symbols and now
> builds the masquerading code based on this symbol rather than the
> IP_NF_TARGET_MASQUERADE symbol, however the nf_nat.h header file
> still uses the old symbol, which leads to a build error when that
> is disabled:
> 
> nf_nat_masquerade_ipv4.c: In function 'nf_nat_masquerade_ipv4':
> nf_nat_masquerade_ipv4.c:59:5: error: 'struct nf_conn_nat' has no member named 'masq_index'
> 
> This changes the header file to do the respective change, and move
> to using the IS_ENABLED() macro in the process, to improve readability
> of the check

David pulled a patch to resolve this yesterday:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=67981fefb20e717cea55b42f9081a833fa46b3be

Thanks anyway.
