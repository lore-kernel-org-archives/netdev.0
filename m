From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Mon, 30 Aug 2004 15:44:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830154430.769d1d59.davem@redhat.com>
References: <1093799632.1073.410.camel@jzny.localdomain>
	<20040830144033.2265a6e6.davem@redhat.com>
	<1093904088.1043.12.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093904088.1043.12.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Aug 2004 18:14:48 -0400
jamal <hadi@cyberus.ca> wrote:

> 4) old kernel +  new tc --> will bomb (sizeof check will fail)
> 
> Cant think of something smart to do with option #4. I have contemplated
> playing with offsetoff() etc. The best thing i can think of right
> now is to complain about it as in that fprintf()
> 
> Thoughts?

Check the size, if it matches the older tc_stats size sans
requeue stat addition, then don't try to reference that struct member.

	if (RTA_PAYLOAD(tb[TCA_STATS]) == sizeof(struct tc_stats_old)) {
		/* report everything sans requeue */
	} else if (RTA_PAYLOAD(tb[TCA_STATS]) == sizeof(struct tc_stats)) {
		/* report all stats, including requeue */
	} else {
		/* report error, etc. */
	}
