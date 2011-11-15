From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v4 3/8] forcedeth: allow to silence "TX
 timeout" debug messages
Date: Tue, 15 Nov 2011 14:27:33 -0800
Message-ID: <20111115142733.5f5ca457@s6510.linuxnetplumber.net>
References: <cover.1321384662.git.david.decotigny@google.com>
	<47650719c85908eb4dff05f5d243cc0e9e181748.1321384662.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	Sameer Nanda <snanda@google.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <47650719c85908eb4dff05f5d243cc0e9e181748.1321384662.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Nov 2011 11:25:36 -0800
David Decotigny <david.decotigny@google.com> wrote:

> From: Sameer Nanda <snanda@google.com>
> 
> This adds a new module parameter "debug_tx_timeout" to silence most
> debug messages in case of TX timeout. These messages don't provide a
> signal/noise ratio high enough for production systems and, with ~30kB
> logged each time, they tend to add to a cascade effect if the system
> is already under stress (memory pressure, disk, etc.).
> 
> By default, the parameter is clear, meaning that only a single warning
> will be reported.
> 
> 
> 
> Signed-off-by: David Decotigny <david.decotigny@google.com>

This (and the counter) should really be generic. I know it is more annoying
to have to solve a generic problem, but putting my distributor hat on,
any solution that is specific to only one driver is not a solution that
is useful.

The control of tx_timeout should be a property of the device, and the statistic
should be available for all devices. There is a problem though, the existing
network device statistics structure is part of ABI and can't grow. You can
add new statistics to netlink and sysfs as attributes, but not for the older
static API's.
