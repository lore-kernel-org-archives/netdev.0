From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 04:44:38 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030522114438.GD2961@netnation.com>
References: <20030520.173607.88482742.davem@redhat.com> <20030522084003.GA22613@netnation.com> <20030522.015815.91322249.davem@redhat.com> <20030522.034058.71558626.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030522.034058.71558626.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, May 22, 2003 at 03:40:58AM -0700, David S. Miller wrote:

> Simon (and others who want to benchmark :-), give this patch below a
> try.

Compiling it now... :)

There's no APIC on this test box, so it's using the XT-PIC.  Production
has an APIC, so I assume the overhead would be less there.

CONFIG_IP_ROUTE_LARGE_TABLES is and was enabled.

My dumb route populator script was just creating /32 routes.

> Anyways, testers please let us know the results.  Note you must
> have CONFIG_IP_ROUTE_LARGE_TABLES (and thus CONFIG_IP_ADVANCED_ROUTER)
> in order to even make use of this stuff.

Nice!  I tested with 300,000 routing table entries and there is no
discernable difference in performance from having an empty table. 
vmstat shows the same idle time as when the routing table is empty.

I enabled the hash growing debug printk, and so I saw this while
populating the route table:

fn_rehash_zone: hash for zone 32 grows from 16
fn_rehash_zone: hash for zone 32 grows from 256
fn_rehash_zone: hash for zone 32 grows from 1024
fn_rehash_zone: hash for zone 32 grows from 2048
fn_rehash_zone: hash for zone 32 grows from 4096
fn_rehash_zone: hash for zone 32 grows from 8192
fn_rehash_zone: hash for zone 32 grows from 16384
fn_rehash_zone: hash for zone 32 grows from 32768
fn_rehash_zone: hash for zone 32 grows from 65536
fn_rehash_zone: hash for zone 32 grows from 131072

I had originally written a patch to try to extend it to 8192, but I think
it was broken.  This definitely seems to fix it.

If you'd like I can try to regenerate a profile, but you probably already
know what it will look like.

Thanks!

Simon- (Zzz...)
