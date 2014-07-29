From: Jean Delvare <jdelvare@suse.de>
Subject: Re: Manual loading of mlx4_en
Date: Tue, 29 Jul 2014 12:34:05 +0200
Message-ID: <20140729123405.6802fbc4@endymion.delvare>
References: <1406627612.4498.16.camel@chaos.site>
	<53D7748A.6040800@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41785 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969AbaG2KeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 06:34:10 -0400
In-Reply-To: <53D7748A.6040800@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amir,

On Tue, 29 Jul 2014 13:16:42 +0300, Amir Vadai wrote:
> On 7/29/2014 12:53 PM, Jean Delvare wrote:
> > I have a usability concern with the mlx4_en ethernet network driver. The
> > module aliases for all the supported devices are on the mlx4_core
> > module, so mlx4_core gets loaded automatically, but mlx4_en does not. I
> > must load mlx4_en manually (kernel 3.12.)
> > 
> > May I ask why the mlx4 driver was split into mlx4_core and mlx4_en in
> > the first place?
> Connect-X card can support both Ethernet and Infiniband link layer - you
> can switch between link layers without replacing the hardware.
> 
> To prevent code duplication, there is a single lower layer driver -
> mlx4_core and two separate upper layer drivers - mlx4_en and mlx4_ib.
> 
> Since kernel 3.13 mlx4_core is loading automatically the upper layer
> driver using request_module():
> b046ffe net/mlx4_core: Load higher level modules according to ports type

Many thanks for the fast and detailed answer! I'll go backport this
commit to kernel 3.12 (and 3.0, hopefully it doesn't have too many
dependencies?)

-- 
Jean Delvare
SUSE L3 Support
