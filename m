From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Tue, 05 Mar 2013 19:15:26 +0200
Message-ID: <5136282E.9080307@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>  <20130227175555.10611.42794.stgit@gitlad.jf.intel.com> <1362501781.2791.19.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362501781.2791.19.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/2013 18:43, Ben Hutchings wrote:
> On Wed, 2013-02-27 at 09:55 -0800, Eliezer Tamir wrote:
>
> Should the units really be cycles or, say, microseconds?  I assume that
> a sysctl setter can do a conversion to cycles so that there's no need to
> multiply every time the value is used.  (If the CPU doesn't have
> constant_tsc or equivalent then this conversion doesn't quite work, but
> then low-latency tunng usually includes disabling frequency scaling.)

We are not very sensitive to this setting, anything on the order of your 
half round time trip plus a few standard deviations works well.
We are busy waiting, so setting a higher value does not change the 
results much.

It does make sense to have this in ms, and it might not matter if the 
dynamic cycles mess with the value too much.

BTW on my machines enabling frequency scaling improves performance in 
many cases.

> Also, this should be a per-device (or even per-NAPI-context?) setting.

Again, I would expect this to depend more on your workload than on the 
NIC, so I would keep this global.
User knobs should be as simple as possible.

 >>+int sysctl_net_ll_poll __read_mostly = 150000;
> Nicely tuned for your specific test system, no doubt. :-)

why don't you try this on your NIC and see ;-)

Thanks for the input,
Eliezer
