From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [HELP] netfilter Kconfig dependency nightmare
Date: Sat, 17 Sep 2005 14:18:28 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0509171407460.3743@scrub.home>
References: <20050916021451.3012196c.akpm@osdl.org>
 <20050916191959.GN8413@sunbeam.de.gnumonks.org> <39e6f6c705091617514457eded@mail.gmail.com>
 <20050917012315.GA29841@mandriva.com> <20050917080714.GV8413@sunbeam.de.gnumonks.org>
 <Pine.LNX.4.61.0509171306290.3743@scrub.home> <20050917112949.GZ8413@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751092AbVIQMSh@vger.kernel.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050917112949.GZ8413@sunbeam.de.gnumonks.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sat, 17 Sep 2005, Harald Welte wrote:

> If CONFIG_IP_NF_CONNTRACK_NETLINK is selected (M or Y), then
> CONFIG_IP_NF_CONNTRACK conditionally adds some code that references
> symbols from nfnetlink.ko (CONFIG_NETFILTER_NETLINK)
> 
> So basically, enabling CONFIG_IP_NF_CONNTRACK_NETLINK creates a dependency
> from CONFIG_IP_NF_CONNTRACK to CONFIG_NETFILTER_NETLINK.  AFAIK, the syntax
> doesn't allow somthing like 
> 
> tristate IP_NF_CONNTRACK
> 	depends on NETFILTER_NETLINK if IP_NF_CONNTRACK_NETLINK!=n

Since IP_NF_CONNTRACK_NETLINK is the one creating the dependency, 
something like this should work:

config IP_NF_CONNTRACK_NETLINK
	depends on IP_NF_CONNTRACK && NETFILTER_NETLINK
	depends on IP_NF_CONNTRACK!=y || NETFILTER_NETLINK!=m

IOW ct_nl depends on (ct && nl) unless (ct=y && nl=m).

bye, Roman
