From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: Prevent ipv6_find_hdr() from returning ENOENT
 for valid non-first fragments
Date: Fri, 09 Jan 2015 16:50:36 +0100
Message-ID: <1420818636.31075.15.camel@stressinduktion.org>
References: <CAFB3abzYNYqtzd_n+Ym0Lo=DYbV0HPU=Tqw=stALNnu188hMKQ@mail.gmail.com>
	 <20150106224706.GA7416@salvia>
	 <CAFB3abwKpR1VqZXUrsexqveAZrA2LTSmTe8a=-H7z2HjAptjwA@mail.gmail.com>
	 <1420627396.26870.36.camel@stressinduktion.org>
	 <20150108205328.GA3361@salvia>
	 <1420756756.1755002.211556745.0418D128@webmail.messagingengine.com>
	 <20150109000546.GA3488@salvia>
	 <CAFB3abwrjp61LLOk3RWwXYEq1g4QZUC8OTKuO2cAr+GbV3n4rw@mail.gmail.com>
	 <1420803255.1978819.211762005.707EFFB9@webmail.messagingengine.com>
	 <20150109114506.GA4857@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rahul Sharma <rsharma@arista.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150109114506.GA4857@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fr, 2015-01-09 at 12:45 +0100, Pablo Neira Ayuso wrote:
> Hi Hannes,
> 
> On Fri, Jan 09, 2015 at 12:34:15PM +0100, Hannes Frederic Sowa wrote:
> > On Fri, Jan 9, 2015, at 08:18, Rahul Sharma wrote:
> > > Hi Pablo,
> > > 
> > > On Fri, Jan 9, 2015 at 5:35 AM, Pablo Neira Ayuso <pablo@netfilter.org>
> > > wrote:
> > > > On Thu, Jan 08, 2015 at 11:39:16PM +0100, Hannes Frederic Sowa wrote:
> > > >> Hi Pablo,
> > > >>
> > > >> On Thu, Jan 8, 2015, at 21:53, Pablo Neira Ayuso wrote:
> > > >> > I'm afraid we cannot just get rid of that !ipv6_ext_hdr() check. The
> > > >> > ipv6_find_hdr() function is designed to return the transport protocol.
> > > >> > After the proposed change, it will return extension header numbers.
> > > >> > This will break existing ip6tables rulesets since the `-p' option
> > > >> > relies on this function to match the transport protocol.
> > > >> >
> > > >> > Note that the AH header is skipped (see code a bit below this
> > > >> > problematic fragmentation handling) so the follow up header after the
> > > >> > AH header is returned as the transport header.
> > > >> >
> > > >> > We can probably return the AH protocol number for non-1st fragments.
> > > >> > However, that would be something new to ip6tables since nobody has
> > > >> > ever seen packet matching `-p ah' rules. Thus, we restore control to
> > > >> > the user to allow this, but we would accept all kind of fragmented AH
> > > >> > traffic through the firewall since we cannot know what transport
> > > >> > protocol contains from non-1st fragments (unless I'm missing anything,
> > > >> > I need to have a closer look at this again tomorrow with fresher
> > > >> > mind).
> > > >>
> > > >> The code in question is guarded by (_frag_off != 0), so we are
> > > >> definitely processing a non-1st fragment currently. The -p match would
> > > >> happen at the time when the packet is reassembled and thus ipv6_find_hdr
> > > >> will find the real transport (final) header at this point (I hope I
> > > >> followed the code correctly here).
> > > >
> > > > Then, Rahul should get things working by modprobing nf_defrag_ipv6.
> > > 
> > > I already had nf_defrag_ipv6 installed when the issue occured. But I
> > > see ip6table_raw_hook returning NF_DROP for the second fragment.
> > 
> > That's what I expected. I think the change only affects hooks before
> > reassembly.
> 
> reassembly happens at NF_IP6_PRI_CONNTRACK_DEFRAG (-400), so that
> happens before NF_IP6_PRI_RAW (-300) in IPv6 which is where the raw
> table is placed.

I tried to reproduce it, but couldn't get non-1st fragments getting
dropped during traversal of the raw table. They get dropped earlier at
during reassembly or pass.

I agree with Pablo, I also would like to see more data.

Thanks,
Hannes
