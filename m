From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [Patch] fix ia64 build failure when CONFIG_SFC=m
Date: Tue, 29 Jul 2008 10:23:53 -0700
Message-ID: <57C9024A16AD2D4C97DC78E552063EA3080BA318@orsmsx505.amr.corp.intel.com>
References: <20080729013650.GH9663@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jgarzik@redhat.com" <jgarzik@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"matthew@wil.cx" <matthew@wil.cx>, Robin Holt <holt@sgi.com>
To: "bhutchings@solarflare.com" <bhutchings@solarflare.com>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20080729013650.GH9663@sgi.com>
Content-Language: en-US
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> CONFIG_SFC=m uses topology_core_siblings() which, for ia64, expects
> cpu_core_map to be exported.  It is not.  This patch exports the needed
> symbol.

Ben,

Before I rush to apply this (or one of the other identical patches that
I've received) ... I'd like to ponder on whether this is the right thing
to do.

Looking at the code in drivers/net/sfc/efx.c I see that you are using
this to compute the number of RX queues based on the number of packages
with the git commit comment saying:

    Using multiple cores in the same package to handle received traffic
    does not appear to provide a performance benefit.  Therefore use CPU
    topology information to count CPU packages and use that as the default
    number of RX queues and interrupts.  We rely on interrupt balancing to
    spread the interrupts across packages.

I have some questions on this:

1) Did you measure on FSB based systems? ... It's kind of sad that the extra
cores are not helping and I wonder why. Do AMD and QPI based systems have
this same limitation?

2) Should Linux have an API to give you a useful number of threads, rather
than make you dig through the topology data structures? At some point cpumask_t
data structure is going to be too big for the kernel stack.

3) Does interrupt balancing always do the right thing to spread your interrupts
across packages?

4) In a hotplug system would you want to adjust the number of threads if cpus
were added or removed?

-Tony
