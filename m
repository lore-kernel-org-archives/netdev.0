From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Tue, 17 May 2011 17:35:46 +0200
Message-ID: <20110517153546.GB3762520@jupiter.n2.diac24.net>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
 <3A54AB469A0294933EAC2257@nimrod.local>
 <m1fwoqoapn.fsf@fess.ebiederm.org>
 <20110517111148.GA3762520@jupiter.n2.diac24.net>
 <m1mxil9z2p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Alex Bligh <alex@alex.org.uk>, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	linux-fsdevel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1mxil9z2p.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2011 at 07:33:18AM -0700, Eric W. Biederman wrote:
> I went the round of keeping a daemon open, saw how much code that
> takes and how fragile that can be in the corner cases and decided to
> patch the kernel to make the interfaces better.

Yes, it is more fragile. I'm currently using it without setns-patched
kernels though, so it's all I have.

(More or less related, I was able to cause a kernel oops on doing a
"find /proc" on setns-patched kernels after bind-mounting /proc; I did
not report it because I'm running grsecurity-patched kernels which tend
to mess with /proc quite a bit... I'll try to reproduce it with your
current patches on an otherwise vanilla kernel.)

> > I also have patches for OpenVPN and pptpd floating around that make it
> > possible to 'cross' namespace boundaries, i.e. the VPN servers listen in
> > one namespace and have their devices in another.
> 
> For openvpn I have managed to get away with simply using an up script. 
> Mostly the script is:
> 
> ip netns add $NSNAME || true
> ip netns exec $NSNAME ip link set lo up
> ip link set $dev netns $NSNAME

Historic annotation: This line used to kernel panic around a year and a
half back - nowadays tap devices do get the netns move right...

> ip netns exec $NSNAME ip link set $dev up
> ip netns exec $NSNAME ifconfig $dev $ifconfig_local netmask $ifconfig_netmask broadcast $ifconfig_broadcast
> 
> With a few extra bits for dns options and routes.  If I had an openvpn
> built with the iproute option I expect I could get away by just wrapping
> iproute.  Not that I would mind a patched openvpn.

I didn't even try to make amends for DNS, I just put 127.0.0.1 and have
caches in each of the namespaces. Wrapping iproute2 would work; one of
the advantages of patching OpenVPN is that the OpenVPN daemon is in the
same namespace as the tap devices and can do all the configuration as
usual.

For pptp, er, well, reading up on how ppp devices behave if you splice
them across namespace boundaries would've taken more time than patching
up the UDP/GRE sockets.

> Personally I think using a vpn in a network namespace seems like a
> killer feature.

Yes, it very much is - it provides very nice and clean solutions to
problems that up to now were usually hacked around with policy routing &
co.


-David
