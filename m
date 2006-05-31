From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 01:45:40 -0600
Message-ID: <20060531014540.A1319@openss7.org>
References: <20060531042908.10463.qmail@web51410.mail.yahoo.com> <20060530235525.A30563@openss7.org> <20060531.001027.60486156.davem@davemloft.net>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964857AbWEaHpn@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060531.001027.60486156.davem@davemloft.net>; from davem@davemloft.net on Wed, May 31, 2006 at 12:10:27AM -0700
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On Wed, 31 May 2006, David Miller wrote:

> From: "Brian F. G. Bidulock" <bidulock@openss7.org>
> Date: Tue, 30 May 2006 23:55:26 -0600
> 
> > For example, it goes to great pains to permute upper order bits in
> > the local address, which for most connections will be a constant
> > value.
> 
> Consider an apache server hosting thousands of virtual
> hosts.  The local address will be different for every
> such host.
> 

If you mean named virtual hosts, no.  They have the same
addresses.

If you mean actual hosts (with an IP address), perhaps in
the low order bits (host number), but unlikely in the high
order bits of the local address (network mask bits).

Also, in such a case the local port number will be rather
constant (80, etc); a condition also not exploited by the
function.

Also consider that the function simply folds the values
rather than permuting bits across the key field by shifting
by some other value than a multiple of 8 between XOR
operations.  This will result in a longer collision list
because the entropy of the key value has not been
sufficiently reduced.

It might sound like I'm complaining, but I'm not.  The
function works for me.  But from a purist point of view,
the hash function is not as efficient as it could be and
there is room for improvement.
