From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 13:50:19 +0200
Message-ID: <20170821135019.5c65b888@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818152601.3760aaec@griffin>
	<20170821061109.GA72656@cran64.bj.intel.com>
	<20170821101925.3f9b36a1@griffin>
	<20170821083900.GA74649@cran64.bj.intel.com>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
	<20170821113514.6f0ec15e@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
	<20170821115106.70fa1e1d@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A5C7@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A5C7-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2017 10:10:38 +0000, Jan Scheurich wrote:
> If I understand correctly, this is a default definition that can be
> overridden by drivers so that we still cannot rely on the Ethernet
> payload always being 32-bit-aligned. 

Not by drivers, by architectures. Only architectures that can
efficiently handle unaligned access (or on which the cost of handling
unaligned access is lower than the cost of unaligned DMA access) set
NET_IP_ALIGN to 0.

> Furthermore, there seem to be machine architectures that cannot
> handle misaligned 32-bit access at all (not even with a performance
> penalty).

Those leave NET_IP_ALIGN to 2.

> Or why else does OVS user space code take so great pain to model
> possible misalignment and provide/use safe access functions?

I don't know how the ovs user space deals with packet allocation. In
the kernel, the network header is aligned in a way that it allows
efficient 32bit access.

> Does Linux kernel code generally ignore this risk?

Given the fact that IPv4 addresses are 32bit, are accessed as such and
one can't say that IPv4 implementation on Linux is non-functional, the
answer is obvious :-)

 Jiri
