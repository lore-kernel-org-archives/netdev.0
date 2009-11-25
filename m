From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance hints
Date: Wed, 25 Nov 2009 12:50:19 +0100
Message-ID: <20091125115019.GG29096@one.firstfloor.org>
References: <20091124.093956.247147202.davem@davemloft.net> <1259085412.2631.48.camel@ppwaskie-mobl2> <4B0C2547.8030408@gmail.com> <20091124.105442.06273019.davem@davemloft.net> <4B0C2CCA.6030006@gmail.com> <87iqczwtia.fsf@basil.nowhere.org> <4B0C4624.9080607@gmail.com> <4B0D0742.2050301@gmail.com> <20091125103713.GF29096@one.firstfloor.org> <4B0D1667.8050506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934521AbZKYLuS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B0D1667.8050506@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2009 at 12:35:03PM +0100, Eric Dumazet wrote:
> > You seem to only have 8 CPUs (one socket) Normally a dual socket nehalem
> > should have 16 with HyperThreading enabled.
> > 
> > For some reason the BIOS is not reporting the other CPU.
> > 
> > You could double check with acpidmp / iasl -d if that's
> > what the BIOS really reports, but normally it should work.
> > 
> 
> Good Lord, I had a CONFIG_NR_CPUS=16 in my .config.

That should be enough for a two socket (2S x 4C x 2T) today,
but of course that will eventually change too.

> Changing to to 32 or 64 seems better :)

That looks weird. It should have worked with CONFIG_NR_CPUS==16 too,
because you only have 16 CPUs and the NR_CPUS should affect APIC
ranges etc.

Something still fishy. I would properly report it.

BTW kernel should give some error message in any case when
there are not enough CPUs I guess. 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
