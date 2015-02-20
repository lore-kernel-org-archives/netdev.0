From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous control
Date: Fri, 20 Feb 2015 13:51:32 +0000
Message-ID: <54E73BE4.2040505@solarflare.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/02/15 01:00, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Add netlink directives and ndo entry to allow VF multicast promiscuous mode.
>
> The administrator wants to allow dedicatedly multicast promiscuous per VF.
If I'm properly understanding, this seems to be an ixgbe-specific option
to work around an ixgbe limitation; is it really appropriate to
implement as a generic net_device_op?
What would this ndo mean to a driver which can support thousands of
multicast groups without MC promisc?  Is it expected to limit the number
of MC groups when this is set to disallow?  Or just fulfil the letter of
the option but not its spirit?  The option doesn't seem to have
well-defined semantics outside of ixgbe.
I would suggest that the right place for this sort of driver-specific
device control is in sysfs.

I'm also a little perplexed as to why anyone would need to disallow
this; what security, or even administrative convenience, is gained by
allowing a VF to join 30 multicast groups but not multicast promiscuous
mode?  Especially as, afaik, there are no restrictions on which
multicast groups are joined, so the VF can receive any particular
multicast traffic it cares about.
