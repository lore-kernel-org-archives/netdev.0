From: Dan Siemon <dan@coverfire.com>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 22 Feb 2005 16:40:40 -0500
Message-ID: <1109108440.5712.17.camel@ganymede>
References: <1106576005.1652.1292.camel@jzny.localdomain>
	 <20050124150634.GT23931@postel.suug.ch>
	 <1106747313.1107.7.camel@jzny.localdomain>
	 <1108134446.5523.22.camel@ganymede>
	 <1108215923.1126.132.camel@jzny.localdomain>
	 <1108246033.7554.18.camel@ganymede> <20050212223204.GG31837@postel.suug.ch>
	 <1108340618.14978.66.camel@ganymede>
	 <20050214142710.GI31837@postel.suug.ch> <1108499294.5465.22.camel@ganymede>
	 <20050215204723.GM31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050215204723.GM31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry, for the tardy response.

On Tue, 2005-15-02 at 21:47 +0100, Thomas Graf wrote:
> I see, well I can extend my objects, I'm even willing to change the
> architecture if needed. The only requirements from my side is to
> keep the generic caching header to allow putting these objects into
> generic caches and keep it simple to readd commit/rollback extesions
> later on.
> 
> What is exactly required to make it GObject aware? I've never worked
> with GOBject so far. Basically a qdisc looks like this at the moment:
> 
> struct rtnl_qdisc
> {
> 	NLHDR_COMMON;		/* common fields required by cache */
> 	NL_TCA_GENERIC(q);	/* generic tc fields (parent, handle, ifindex ...) */
> 	void *opts;		/* qdisc specific options (e.g.  rtnl_sch_fifo) */
> };
> 
> The NLHDR_COMMON must stay first, the ordering of the others doesn't
> matter.

That could be a problem.  The GObject struct must be at the start so
that all sub-classes can be operated on with the g_object_ functions.
The only way to make these objects work with your caching scheme would
be to make a sub-class of GObject with the caching information.  This
would have the benefit of adding ref counting etc.

The following URL will give you a bit of background on GObject.
http://www.le-hacker.org/papers/gobject/

-- 
OpenPGP key: http://www.coverfire.com/files/pubkey.txt
Key fingerprint: FB0A 2D8A A1E9 11B6 6CA3  0C53 742A 9EA8 891C BD98
