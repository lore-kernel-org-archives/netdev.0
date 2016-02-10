From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2] iplink: display rx nohandler stats
Date: Tue, 9 Feb 2016 17:41:02 -0800
Message-ID: <20160209174102.7a2a1aee@xeon-e3>
References: <20160208183254.GB4566@redhat.com>
	<20160208113821.0ba26eb0@xeon-e3>
	<1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160209.034023.50018877443465909.davem@davemloft.net>
	<56B9C5DC.4050505@mojatatu.com>
	<20160209111757.4d7d65c1@xeon-e3>
	<20160209235134.GA15438@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160209235134.GA15438@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 Feb 2016 18:51:35 -0500
Jarod Wilson <jarod@redhat.com> wrote:

> On Tue, Feb 09, 2016 at 11:17:57AM -0800, Stephen Hemminger wrote:
> > Support for the new rx_nohandler statistic.
> > This code is designed to handle the case where the kernel reported statistic
> > structure is smaller than the larger structure in later releases (and vice versa).
> 
> This seems to work here, for the most part. However, if you are running a
> kernel with the new counter, and the counter happens to contain 0, aren't
> we going to not print anything?

That is the desirable outcome, since if run on older system the
output format will not change from current format.


> I've got a tweaked version here locally that gets a touch messy, where I
> get a count of members from RTA_DATA(IFLA_STATS{,64} / sizeof(__u{32,64}),
> pass that into the print functions, and key off that length for whether or
> not to print the extra members, so they'll show up even when 0, if they're
> supported. This does rely on strict ordering of the struct members, no
> reordering, no removals, etc., but I think everyone is already in favor of
> that. Looks like the same sort of length checks could be used for
> rx_compressed and tx_compressed as well, as I think they fall victim to
> the same issue of not printing if those counters are legitimately 0. Yes,
> it's a little uglier, and more brittle, but more accurate output.
> 

I don't like the added complexity.
