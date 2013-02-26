From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [E1000-devel] [PATCH RESEND 3/3] e1000e: fix accessing to
 suspended device
Date: Tue, 26 Feb 2013 23:35:10 +0000
Message-ID: <1361921710.2996.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130225051010.12689.28611.stgit@zurg>
	 <20130225051911.12689.11167.stgit@zurg> <512C0B59.4020209@intel.com>
	 <512C8889.80107@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512C8889.80107@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-26 at 14:03 +0400, Konstantin Khlebnikov wrote:
> Waskiewicz Jr, Peter P wrote:
> > On 2/24/2013 9:19 PM, Konstantin Khlebnikov wrote:
> >> This patch fixes some annoying messages like 'Error reading PHY register' and
> >> 'Hardware Erorr' and saves several seconds on reboot.
> >
> > Any networking-related patches should also include netdev@vger.kernel.org.
> 
> Yeah, I forgot about this, since I came here from PCI-bus side, not from the network =)
> 
> >
> > I'm also a bit confused how the changes below match the patch description.
>  > Elaborating a bit more how the changes suppress the messages might be a good thing.
> 
> Patch eliminates reason of these errors -- now driver will wake up
> the device before accessing to its registers.
[...]

But e1000e calls netif_device_detach() when entering run-time suspend.
That currently prevents any ethtool operations from running until it
resumes.

(This is definitely a misfeature of either the ethtool core or e1000e.
It is absolutely ridiculous that I can't check the PHY settings of an
e1000e - or even driver information! - when the link is down.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
