From: Jes Sorensen <jes@sgi.com>
Subject: Re: kmalloc_node returns unaligned memory
Date: 13 Mar 2006 09:49:34 -0500
Message-ID: <yq0y7zev1q9.fsf@jaguar.mkp.net>
References: <20060313144513.GA9542@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jaroslav Kysela <perex@suse.de>,
	netdev@vger.kernel.org, Dean Nelson <dcn@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751423AbWCMOtg@vger.kernel.org>
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20060313144513.GA9542@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Olaf" == Olaf Hering <olh@suse.de> writes:

Olaf> kmalloc_node returns unaligned pointers on powerpc, when
Olaf> CONFIG_DEBUG_SLAB is enabled. This makes iptables very
Olaf> unhappy. It checks the alignment in
Olaf> net/ipv6/netfilter/ip6_tables.c:check_entry_size_and_hooks().
Olaf> __alignof__(struct ip6t_entry) returns 8. But returned pointers
Olaf> from xt_alloc_table_info() are unaligned:

Hi Olaf,

I believe this is expected behavior ;-(

We have the same problem with the XPC driver for the SN2 which resulted
in a wrapper macro being created for it.

Some sort of SLAB_HWCACHE_ALIGN flag to Slab that was always respected
for this would be nice.

Cheers,
Jes
