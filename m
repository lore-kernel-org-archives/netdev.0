From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (2/4) packet scheduler bad TDIFF_SAFE in csz
Date: Tue, 29 Jun 2004 15:49:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629154907.5a335900@dell_ss3.pdx.osdl.net>
References: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
	<20040629144506.0649d217.davem@redhat.com>
	<1088547756.1040.5.camel@jzny.localdomain>
	<20040629152822.4fa2e1c4.davem@redhat.com>
	<1088549025.1046.12.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088549025.1046.12.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Jun 2004 18:43:45 -0400
jamal <hadi@cyberus.ca> wrote:

> 
> Sounds like good logic to me.
> BTW, that jiffies fix, statemnt from Steve:
> > The downside is the overhead of a function call, and a cache miss in >
> >get_jiffies_64.
> 
> Is this overhead on 32 bit machines or applies on 64 bit as well?
> Note that code is used in the fast path.

jiffies.h

#if (BITS_PER_LONG < 64)
u64 get_jiffies_64(void);
#else
static inline u64 get_jiffies_64(void)
{
	return (u64)jiffies;
}
#endif
