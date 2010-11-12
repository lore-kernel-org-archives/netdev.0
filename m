From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 18:49:02 -0800 (PST)
Message-ID: <20101111.184902.233699247.davem@davemloft.net>
References: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
	<20101111.182939.258124014.davem@davemloft.net>
	<1289529269.3090.207.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hadi-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	vladislav.yasevich-VXdhtT5mjnY@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, daniel.lezcano-GANU6spQydw@public.gmane.org,
	jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
To: drosenberg-PiUznwcHFHrqlBn2x/YWAg@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1289529269.3090.207.camel@Dan>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Rosenberg <drosenberg-PiUznwcHFHrqlBn2x/YWAg@public.gmane.org>
Date: Thu, 11 Nov 2010 21:34:29 -0500

> 
>> I want whatever you replace it with to be equivalent for
>> object tracking purposes.
> 
> In nearly all of the cases I fixed, the socket inode is already
> provided, which serves as a perfectly good unique identifier.  Would you
> prefer I include that information twice?

The problem is that the socket inode is not available in a certain
subclass of cases, so the transformation is not equivalent.

Why not attack this at the heart of where your concern is, and hack
the %p format handling to do whatever it is you like instead of
patching code all over the tree?
