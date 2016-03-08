From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Tue, 08 Mar 2016 21:11:09 +0000
Message-ID: <24950.1457471469@warthog.procyon.org.uk>
References: <20160308.151311.928321529565045584.davem@davemloft.net> <20160307143806.18567.30020.stgit@warthog.procyon.org.uk> <23389.1457390714@warthog.procyon.org.uk> <29908.1457437197@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160308.151311.928321529565045584.davem@davemloft.net>
Content-ID: <24949.1457471469.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> > One could argue, I suppose, that things should've been arranged that the
> > RxRPC client would manage the lifetime of each connection it sets up,
> > rather than both ends letting it lapse by mutual loss of interest.  But
> > you *still* have to have a timeout, lest the client die and not close its
> > connection.
> 
> But the point is if there is no limitation on the number of these connections
> that can be setup.... wait for troubles.
> 
> And if you try to put in some kind of limit to handle this, it's then
> easy for the bad guy to block out other legitimate users.

I can put in a limit per peer, where a 'peer' is either a particular remote
UDP port or particulat remote host.  TCP has this by virtue of having a
limited number of ports available per IP address.  But if I have 10 IP
addresses available, I can attempt to set up half a million TCP connections to
a server simultaneously.  If I have access to a box that has an NFS mount on
it, I can potentially open sufficient TCP ports that the NFS mount can't make
a connection if it's not allowed to use privileged ports.

Am I right in thinking that you have decided that it can't be done and
shouldn't be done?

David
