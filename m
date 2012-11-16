From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Make IPv6 packet parsing
	dependent on IPv6 config
Date: Fri, 16 Nov 2012 09:36:53 -0800
Message-ID: <CAEP_g=9aOQ=B35dufSv8crw1OPZB=n21+QU04W96ak-A0GYaMg@mail.gmail.com>
References: <50a5c2e5.lgIvZwesNLp78CVD%fengguang.wu@intel.com>
	<1353080434-14165-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1353080434-14165-1-git-send-email-vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Fri, Nov 16, 2012 at 7:40 AM, Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Openvswitch attempts to use IPv6 packet parsing functions without
> any dependency on IPv6 (unlike every other place in kernel).  Pull
> the IPv6 code in openvswitch togeter and put a conditional that's
> dependent on CONFIG_IPV6.
>
> Resolves:
> net/built-in.o: In function `ovs_flow_extract':
> (.text+0xbf5d5): undefined reference to `ipv6_skip_exthdr'
>
> Signed-off-by: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

(Sorry for duplicates received, the original message had a typo in the
mailing list address.)

Doesn't this move in the opposite direction of your patches to make
IPv6 GSO/GRO always available?  The packets being processed here are
generally created by the guest but with Open vSwitch running on the
host.  Also, ipv6_skip_exthdr() is in exthdrs_core.c, so it actually
is always available.  I suspect that the real problem is that the
dependency on the ipv6 directory changed to CONFIG_INET and Open
vSwitch should now depend on this.
