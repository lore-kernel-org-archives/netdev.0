From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 19:36:31 +0100
Message-ID: <4B6870AF.6060109@trash.net>
References: <1264813832.2793.446.camel@tonnant>	 <1265023437.2848.30.camel@edumazet-laptop>	 <1265035970.2848.50.camel@edumazet-laptop>	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>	 <1265036548.2848.55.camel@edumazet-laptop>	 <1265108690.2861.118.camel@tonnant> <1265110504.2861.135.camel@tonnant>	 <1265129192.2861.141.camel@tonnant> <4B685756.8010107@trash.net>	 <1265130426.2861.158.camel@tonnant>	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com> <1265134598.2861.191.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265134598.2861.191.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Masters wrote:
> On Tue, 2010-02-02 at 19:58 +0200, Alexey Dobriyan wrote:
> 
>> Yes, moving to init_net-only function is fine.
> 
> So moving the "setup up fake conntrack" bits to init_init_net from
> init_net still results in the panic, which means that the use count
> really is dropping to zero and we really are trying to free it when
> using multiple namespaces. Per ns is probably an easier way to go.

Agreed, that will also avoid problems in the future with the
ct_net pointer pointing to &init_net. I'll take care of this
tommorrow.
