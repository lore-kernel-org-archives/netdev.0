From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Sat, 8 Jan 2005 15:54:57 +0100
Message-ID: <20050108145457.GZ26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <20050104223612.GN26856@postel.suug.ch> <1104894728.1117.56.camel@jzny.localdomain> <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain> <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105105511.1046.77.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105105511.1046.77.camel@jzny.localdomain> 2005-01-07 08:45
> > 3) Fill out a pkt_info struct with ptr and off2 so we don't lose
> >    hashing capabilities
> 
> And this is why i dont like it. 

What's the reason for not liking it? I know it's not a perfect solution
in terms of layers but having the classifier sharing already gathered
information to an ematch is not a bad thing.

> I think the u32 changes are one-shot if you want to avoid lotsa #ifdefs.
> Someone sends you a old sel, then convert it to a new one for storage.
> Dumping is a little trickier, need some way to recognize old style
> request. 

The easiest way is to introduce a new TLV type and regard configuration
requests carrying the old type in compatibility mode.

> The trick would be to always use sel2 and present no kconfig options for back 
> compat. We need to figure out how to recognize an old style dump and we are
> set.

Given we always use the new method by converting old style parameters
and we use em_u32 as u32 key we would need to put a dependcy on ematch
&& em_u32 for cls_u32.

> Above you are trying to insert off2 into the info (what i said i didnt
> like) - how are you going to achieve the same with a standalone en_u32
> from say you basic classifier?

I won't and it's not necessary, one can use u32 if he requires the
nexthdr capabilities or otherwise use em_cmp support the skb layers.
(Which i know is not perfect since the pointers to those layers are
not provided all the time).
