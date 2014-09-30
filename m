From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/7] netfilter: Convert print_tuple functions to return
 void
Date: Tue, 30 Sep 2014 06:04:56 -0700
Message-ID: <1412082296.4302.101.camel@joe-AO725>
References: <20140929124246.3e39dac8@gandalf.local.home>
	 <cover.1412031505.git.joe@perches.com>
	 <f2e8cf8df433a197daa62cbaf124c900c708edc7.1412031505.git.joe@perches.com>
	 <20140930102221.GB2707@dhcp128.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Petr Mladek <pmladek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140930102221.GB2707@dhcp128.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-30 at 12:22 +0200, Petr Mladek wrote:
> On Mon 29-09-14 16:08:22, Joe Perches wrote:
> > Since adding a new function to seq_file (seq_is_full)
> > there isn't any value for functions called from seq_show to
> > return anything.   Remove the int returns of the various
> > print_tuple/<foo>_print_tuple functions.

[a bunch of quoted stuff]

Please remember to cut out from your replies the unnecessary old stuff.
It can take quite awhile to scan through looking for your comments.

> > diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
[]
> > @@ -202,9 +203,8 @@ static int ct_seq_show(struct seq_file *s, void *v)
> >  	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
> >  		goto release;
> >  
> > -	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
> > -			l3proto, l4proto))
> > -		goto release;
> > +	print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
> > +		    l3proto, l4proto);
> 
> To be precise, we should add:
> 
> 	if (seq_overflow(s))
> 		goto release;

Precision isn't all that useful when checking seq_<output>.

There really isn't much value in checking each possible
overflow site.  A periodic check prior to or in the middle
of a more costly/longish operation should be acceptable.

The entire block that precedes any seq buffer full test will
be redone when the buffer is expanded.

