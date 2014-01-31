From: David Rientjes <rientjes@google.com>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Fri, 31 Jan 2014 15:22:10 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401311521170.18890@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1401180036020.18419@dinf> <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.DEB.2.02.1401181101220.579@dtop> <alpine.DEB.2.02.1401292301070.5905@dtop> <1391134615.28432.83.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAADnVQ+vCikFY-te2U8wD+ustNW-o6Cqs8ye5ZfyNcU6vPQzNA@mail.gmail.com> <alpine.DEB.2.10.1401301951060.5516@dinf> <alpine.DEB.2.02.1401311315110.27318@chino.kir.corp.google.com> <alpine.DEB.2.02.1401311407190.17834@dtop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1401311407190.17834@dtop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Jan 2014, dormando wrote:

> > CONFIG_SLUB_DEBUG_ON will definitely be slower but can help to identify
> > any possible corruption issues.
> >
> > I'm wondering if you have CONFIG_MEMCG enabled and are actually allocating
> > slab in a non-root memcg?  What does /proc/self/cgroup say?
> >
> 
> /proc/self/cgroup is empty on these hosts. CONFIG_MEMCG is enabled though.
> 

It _looks_ like the cmpxchg_double() so seeing if there is anything else 
funny going on with CONFIG_SLUB_DEBUG_ON would definitely be helpful; 
otherwise, try using CONFIG_SLAB is Eric suggested and seeing if the 
problem goes away.
