From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Mon, 30 Aug 2004 16:05:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830160558.5ff0e9b2@dell_ss3.pdx.osdl.net>
References: <1093799632.1073.410.camel@jzny.localdomain>
	<20040830144033.2265a6e6.davem@redhat.com>
	<1093904088.1043.12.camel@jzny.localdomain>
	<20040830154430.769d1d59.davem@redhat.com>
	<1093906592.1037.32.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093906592.1037.32.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Aug 2004 18:56:32 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2004-08-30 at 18:44, David S. Miller wrote:
> > On 30 Aug 2004 18:14:48 -0400
> > jamal <hadi@cyberus.ca> wrote:
> 
> > Check the size, if it matches the older tc_stats size sans
> > requeue stat addition, then don't try to reference that struct member.
> > 
> > 	if (RTA_PAYLOAD(tb[TCA_STATS]) == sizeof(struct tc_stats_old)) {
> > 		/* report everything sans requeue */
> > 	} else if (RTA_PAYLOAD(tb[TCA_STATS]) == sizeof(struct tc_stats)) {
> > 		/* report all stats, including requeue */
> > 	} else {
> > 		/* report error, etc. */
> > 	}
> 
> Sounds reasonable to me. Some of the BSDs do this to maintain old compat
> - just means keeping old struct around. Steve, agreeable to you? 
> 
> Change to both kernel and user space or just user space?

I have no problem but easier to just do something:
	struct tc_stats mystats;

	memset(&mystats, 0, sizeof(mystats));
	memcpy(&mystats, RTA_DATA(tb[TCA_STATS]), RTA_PAYLOAD(tb[TCA_STATS]));

that way it can grow as much as we want and don't have v1, v2, v3, ... 
size structures.
