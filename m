From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next iproute2] iplink: display rx nohandler stats
Date: Wed, 10 Feb 2016 08:20:59 -0500
Message-ID: <20160210132059.GB17296@redhat.com>
References: <20160208183254.GB4566@redhat.com>
 <20160208113821.0ba26eb0@xeon-e3>
 <1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160209.034023.50018877443465909.davem@davemloft.net>
 <56B9C5DC.4050505@mojatatu.com>
 <20160209111757.4d7d65c1@xeon-e3>
 <20160209235134.GA15438@redhat.com>
 <20160209174102.7a2a1aee@xeon-e3>
 <1455079958.21021.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455079958.21021.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 09, 2016 at 08:52:38PM -0800, Eric Dumazet wrote:
> On Tue, 2016-02-09 at 17:41 -0800, Stephen Hemminger wrote:
> > On Tue, 9 Feb 2016 18:51:35 -0500
> > Jarod Wilson <jarod@redhat.com> wrote:
> > 
> > > On Tue, Feb 09, 2016 at 11:17:57AM -0800, Stephen Hemminger wrote:
> > > > Support for the new rx_nohandler statistic.
> > > > This code is designed to handle the case where the kernel reported statistic
> > > > structure is smaller than the larger structure in later releases (and vice versa).
> > > 
> > > This seems to work here, for the most part. However, if you are running a
> > > kernel with the new counter, and the counter happens to contain 0, aren't
> > > we going to not print anything?
> > 
> > That is the desirable outcome, since if run on older system the
> > output format will not change from current format.
> 
> The problem here is that a change in output might break some user
> scripts using sed/whatever games.
> 
> So it might be better to output a zero field, so that such breakages are
> detected early, even if no packet was dropped at the time the new kernel
> was tested.
> 
> Having a binary that adds the new field only in some cases hides the
> change. It looks fine for us humans, but not for programs processing the
> output.

On my test setup, my bond's active interface currently has 0, while the
backup interface has a few thousand, so I can alternate back and forth
checking the interfaces, and one doesn't print the counter while the other
does, which is what seemed odd to me and prompted the added ugliness. But
most setups (anything outside of bond/team currently) should never have
this counter incremented, we do have prior art with the compressed fields,
and scripts really probably ought to be scraping stats out of sysfs rather
than using ip, so I can sort of understand not wanting the added ugliness.
I do tend to prefer consistency though.

-- 
Jarod Wilson
jarod@redhat.com
