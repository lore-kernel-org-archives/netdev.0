From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 00/10] Transparent proxying patches version 4
Date: Wed, 03 Jan 2007 17:33:57 +0100
Message-ID: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

The following set of patches implement transparent proxying support
loosely modeled on the Linux 2.2 transparent proxying functionality.

In the last few years we've been maintaining a set of patches
implementing Netfilter NAT to provide similar functionality. However,
as time passed, more and more bugs surfaced, some of which were not
possible to fix using that approach. Also, those patches required
modification of user-space application code and the "API" provided was
neither clean nor easy to use.

So instead of using NAT to dynamically redirect traffic to local
addresses, we now rely on "native" non-locally-bound sockets and do
early socket lookups for inbound IPv4 packets. These lookups are done
in a separate Netfilter/iptables module, so there are only negligible
performance implications of building transparent proxying support as a
module and then not loading it.

Small modifications were also necessary in IP/TCP/UDP core code to
support the Netfilter modules. All those have been functionally split
out into stand-alone patches among which there are no direct
dependencies. Among these changes are ones which I think might be
potentially risky, especially the core IPv4 routing code changes.

Also please note that at the moment only IPv4 support is implemented,
but opposed to the NAT-based approach taken by older TProxy versions
IPv6 support is possible this way.

Comments welcome...

-- 
 Regards,
  Krisztian Kovacs
