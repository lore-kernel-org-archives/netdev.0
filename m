From: Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Tue, 22 Nov 2011 21:34:18 -0800
Message-ID: <20111123053418.GJ3344@sequoia.sous-sol.org>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<20111122.155006.361847516719132107.davem@davemloft.net>
	<20111122151854.198da33d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111122151854.198da33d-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org) wrote:
> Maybe someone with more insight than me can explain the relationship
> between Openflow and Open vSwitch. It maybe that the portability
> of Openflow makes the old qdisc, classifiers to use/implement.

I'm sure I can't answer the last bit as well as you'd like.  But openflow
is the control plane protocol between a controller and a switch.
The controller's job is to program the switch to enforce the controller's
view of network policy.  For ovs, the protocol termination is essentially
in userspace.

The switch's flow table is managed via the controller and obviously
consulted on the datapath in the kernel.  I think Jesse was already clear
that portability concerns were constrained to userspace.  You could
imagine all kinds of funky ways that userspace could in turn ask the
kernel to enforce the flow table actions that the controller requested.

Your and Jamal's questions seem pretty clear...what does ovs do that
tc can't/doesn't and is that a fundamental gap, a cumbersome interface,
or a need to port existing functionality.

The only part I was unclear on in that question is whether you're
talking about the internals only, or also the netlink interface?

thanks,
-chris
