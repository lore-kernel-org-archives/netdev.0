From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Wed, 14 Jul 2010 15:22:49 +0300
Message-ID: <1279110169.20985.41.camel@chilepepper>
References: <20100713001115.GA3751@sortiz-mobl>
	 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
	 <4C3C28EC.2000302@netfilter.org> <1279016596.12673.11.camel@chilepepper>
	 <4C3C9671.5090503@netfilter.org>  <4C3DA3F4.1060807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Changli Gao <xiaosuo@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C3DA3F4.1060807@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-07-14 at 13:48 +0200, ext Patrick McHardy wrote:
> On 13.07.2010 18:38, Pablo Neira Ayuso wrote:
> > On 13/07/10 12:23, Luciano Coelho wrote:
> >> On Tue, 2010-07-13 at 10:50 +0200, ext Pablo Neira Ayuso wrote:
> >>> On 13/07/10 08:18, Changli Gao wrote:
> >>>> On Tue, Jul 13, 2010 at 8:11 AM, Samuel
> >>>> Ortiz<sameo@linux.intel.com>  wrote:
> >>>>>
> >>>>> The userspace notification Xtables target sends a netlink notification
> >>>>> whenever a packet hits the target. Notifications have a label
> >>>>> attribute
> >>>>> for userspace to match it against a previously set rule. The rules
> >>>>> also
> >>>>> take a --all option to switch between sending a notification for all
> >>>>> packets or for the first one only.
> >>>>> Userspace can also send a netlink message to toggle this switch
> >>>>> while the
> >>>>> target is in place. This target uses the nefilter netlink framework.
> >>>>>
> >>>>> This target combined with various matches (quota, rateest, etc..)
> >>>>> allows
> >>>>> userspace to make decisions on interfaces handling. One could for
> >>>>> example
> >>>>> decide to switch between power saving modes depending on estimated
> >>>>> rate
> >>>>> thresholds.
> >>>>>
> >>>>
> >>>> It much like the following iptables rules.
> >>>>
> >>>> iptables -N log_and_drop
> >>>> iptables -A log_and_drop -j NFLOG --nflog-group 1 --nflog-prefix
> >>>> "log_and_drop"
> >>>> iptables -A log_and_drop -j DROP
> >>>>
> >>>> ...
> >>>> iptables ... -m quota --quota-bytes 20000 -j log_and_drop
> >>>> ...
> >>>
> >>> Indeed, this looks to me like something that you can do with NFLOG and
> >>> some combination of matches.
> >>
> >> Is it possible to have the NFLOG send only one notification to the
> >> userspace?
> > 
> > Not possible, but you could easily extend NFLOG to implement this
> > feature if it's not possible to do what you need with the existing
> > matches/targets. This NOTIF infrastructure is redundant and it looks
> > like a subset of NFLOG.
> 
> If you're using connection tracking, you can use conntrack marks
> to avoid sending more than a single message:
> 
> iptables ... -m connmark --mark 0x1/0x1 -j RETURN
> iptables ... -j NFLOG ...
> iptables ... -j CONNMARK --set-mark 0x1/0x1

Cool, thanks.

It seems that there are lots of possibilities to get this to work, but
this is starting to get quite complex.  I would still prefer having the
NFNOTIF module included, since we would be able to do what we want in a
very simple way.  It's also probably much more efficient that using
several rules, which would increase the CPU usage considerably (in our
device we are already reaching the limit of a reasonable CPU resource
usage with high throughput WLAN connections).

While I agree that it is possible to achieve the NFNOTIF functionality
with existing modules, I still think there is a "niche" for such module,
because it is very simple, has a very clear purpose and would make the
ruleset simpler and more efficient.

Does this make any sense?


-- 
Cheers,
Luca.

