From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6]
 iptables CLUSTERIP target)
Date: Fri, 22 Oct 2004 16:05:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022160559.28f9c540.davem@davemloft.net>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org>
	<E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, lmb@suse.de, ahu@ds9a.nl, hch@infradead.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 07:31:07 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Initially I considered an interface where kernel users can register
> themselves using a string as the key.  But I soon realised that we
> could simply allow the netlink_family field to be an arbitrary integer
> that is used as a key to a hash table.

(I assume you mean "nl_family" not "netlink_family" :-)

> The CPU cost of the hash table isn't too bad since you'll only be
> looking it up when the socket is created.

I'm fine with this idea, however please tell me how you intend
to make things like ->getname() behave?

I would also suggest to start with values > AF_MAX, so that people
sticking other AF_* values in there by accident are caught.
