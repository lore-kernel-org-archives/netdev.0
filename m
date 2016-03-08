From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next 2/3] ipv6: per netns fib6 walkers
Date: Tue, 8 Mar 2016 08:05:44 +0100
Message-ID: <20160308070544.GA8710@unicorn.suse.cz>
References: <cover.1457085016.git.mkubecek@suse.cz>
 <6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
 <CAM_iQpUxHX71GRmnmcvXpOX4P4mzJXpoYmcYhcZi2CXxEK4XFQ@mail.gmail.com>
 <CAM_iQpXynuGx2F6RdeFcyCH7qSxPv0Q0p7etwTTje07hMSaZbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpXynuGx2F6RdeFcyCH7qSxPv0Q0p7etwTTje07hMSaZbw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2016 at 04:28:26PM -0800, Cong Wang wrote:
> On Mon, Mar 7, 2016 at 4:26 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Fri, Mar 4, 2016 at 2:59 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> >>  static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
> >>  {
> >> +#ifdef CONFIG_NET_NS
> >> +       struct net *net = iter->p.net;
> >> +#else
> >> +       struct net *net = &init_net;
> >> +#endif
> >> +
> >
> > You should pass the struct net pointer to ipv6_route_seq_setup_walk()
> > instead of reading it by yourself.

I considered this. While it probably wouldn't bring any extra overhead
as the function is going to be inlined anyway, it didn't look really
nice. I gues I'll use read_pnet() as David suggested; I just didn't
realize the reason it's a macro in !CONFIG_NET_NS case is to allow
passing a pointer to non-existent struct member.

> > I don't find anyone actually using iter->p, it probably can be just removed.
> 
> Er, seq_file_net() uses it... but callers already call it.

Not only seq_file_net(). The whole infrastructure assumes private data
start with an instance of struct seq_net_private and seq_open_net()
initializes it.

                                                        Michal Kubecek
