From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 2 Jun 2003 11:05:37 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030602180537.GB30957@netnation.com>
References: <20030522.015815.91322249.davem@redhat.com> <20030522.034058.71558626.davem@redhat.com> <20030522114438.GD2961@netnation.com> <20030522.153330.74735095.davem@redhat.com> <20030529205125.GA30058@netnation.com> <16091.11735.721251.925522@robur.slu.se> <20030602151852.GA6070@netnation.com> <16091.32021.75335.227150@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16091.32021.75335.227150@robur.slu.se>
List-Id: netdev.vger.kernel.org

On Mon, Jun 02, 2003 at 06:36:37PM +0200, Robert Olsson wrote:

>  We are given more work than we have resources for (max_size) what else than 
>  refuse can we do?  But yes we have invested pretty much work already. 

Well, this is the problem.  We do not and cannot know which entries we
really want to remember (legitimate traffic).  Adding code to actually
refuse new dst entries is just going to make the DoS effective, which is
NOT what we want.

>  Also remember we are looking into runs were 100% of incoming traffic has one 
>  new dst for every packet. So how is the situation in "real life"? 
>  In case of multiple devices at least NAPI gives all devs it's share. 

Right, so, when we are traffic saturated, we want to make sure the whole
route cache and route path is as fast as possible.  Recycling dst entries
by simpy rewriting and rehashing them rather than allocating new and
eventually freeing them all in the garbage collection cycle should reduce
allocator overhead.  If this is only done when the table is full, I don't
see any downside...if this is in fact doable, that is. :)

Simon-
