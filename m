From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Use RCU for tcp_ehash lookup
Date: Wed, 1 Sep 2004 22:43:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901224306.7dd80458.davem@davemloft.net>
References: <20040831125941.GA5534@in.ibm.com>
	<20040831135419.GA17642@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vatsa@in.ibm.com, davem@redhat.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, dipankar@in.ibm.com, paulmck@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040831135419.GA17642@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 15:54:20 +0200
Andi Kleen <ak@suse.de> wrote:

> And it should also fix the performance problems with
> cat /proc/net/tcp on ppc64/ia64 for large hash tables because the rw locks 
> are gone.

Time to convert netstat et al. over the netlink too.

> > - I presume that one of the reasons for keeping the hash table so big is to
> >   keep lock contention low (& to reduce the size of hash chains). If the lookup
> >   is made lock-free, then could the size of the hash table be reduced (without
> >   adversely impacting performance)?
> 
> Definitely worth trying IMHO. The current hash tables are far
> too big. I would do that as followon patches though.

The hashes are big to make the hash effective, not to help the locking
contention.
