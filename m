From: David Lamparter <equinox-cEeocvCgqOOsTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Tue, 17 May 2011 13:11:48 +0200
Message-ID: <20110517111148.GA3762520@jupiter.n2.diac24.net>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<3A54AB469A0294933EAC2257@nimrod.local>
	<m1fwoqoapn.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1fwoqoapn.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 07, 2011 at 07:18:44AM -0700, Eric W. Biederman wrote:
> You can read the processes network namespace by opening
> /proc/<pid>/ns/net.  Unfortunately comparing the network
> namespaces for identity is another matter.  You will probably
> be better off simply forcing the routing daemon to start
> in the desired network namespace in it's initscript.
> 
> For purposes of clarity please have a look at my work in
> progress patch for iproute2.  This demonstrates how I expect
> userspace to work in a multi-network namespace world.
> 
[...]
> Subject: [PATCH] iproute2:  Add processless netnwork namespace support.
[...]
> Configuration specific to a network namespace that
> would ordinarily be stored under /etc/ is stored under
> /etc/netns/<name>.  For example if the dns server
> configuration is different for your vpn you would
> create a file /etc/netns/myvpn/resolv.conf.
> 
> File descriptors that can be used to manipulate a
> network namespace can be created by opening
> /var/run/netns/<NAME>.
> 
> This adds the following commands to iproute.
> ip netns add NAME
> ip netns delete NAME
> ip netns monitor
> ip netns list
> ip netns exec NAME cmd ....
> ip link set DEV netns NAME

funny, this is almost exactly what my code does - though you're probably
doing it better and have more features ;)
http://git.spaceboyz.net/equinox/vrf-tools.git/
git://spaceboyz.net/equinox/vrf-tools.git

It currently forks off a daemon to keep the namespace open; attaching is
not possible yet, but opening a socket in a different namespace is.

Most of the actual management (mounting things & co.) I offloaded to
some shell scripts; I use it together with GNU screen (which makes it
very nice to grab one of the namespaces and start/stop/manage/...
things).

I also have patches for OpenVPN and pptpd floating around that make it
possible to 'cross' namespace boundaries, i.e. the VPN servers listen in
one namespace and have their devices in another.


-David
