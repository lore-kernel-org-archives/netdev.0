From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 10 Jan 2005 08:26:22 -0500
Message-ID: <1105363582.1041.162.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <20050104223612.GN26856@postel.suug.ch>
	 <1104894728.1117.56.camel@jzny.localdomain>
	 <20050105110048.GO26856@postel.suug.ch>
	 <1104931991.1117.152.camel@jzny.localdomain>
	 <20050105144514.GQ26856@postel.suug.ch>
	 <1105019225.2312.7.camel@jzny.localdomain>
	 <20050106194102.GW26856@postel.suug.ch>
	 <1105105511.1046.77.camel@jzny.localdomain>
	 <20050108145457.GZ26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050108145457.GZ26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-08 at 09:54, Thomas Graf wrote:
> * jamal <1105105511.1046.77.camel@jzny.localdomain> 2005-01-07 08:45
> > > 3) Fill out a pkt_info struct with ptr and off2 so we don't lose
> > >    hashing capabilities
> > 
> > And this is why i dont like it. 
> 
> What's the reason for not liking it?  I know it's not a perfect solution
> in terms of layers but having the classifier sharing already gathered
> information to an ematch is not a bad thing.

I think its _a hack_ Thomas ;-> Mostly because it has dependency on u32.
off2 doesnt exist on any other classifier and the basic ematch should be
usable by any classifier.


> The easiest way is to introduce a new TLV type and regard configuration
> requests carrying the old type in compatibility mode.
> 

Sounds reasonable.

> > The trick would be to always use sel2 and present no kconfig options for back 
> > compat. We need to figure out how to recognize an old style dump and we are
> > set.
> 
> Given we always use the new method by converting old style parameters
> and we use em_u32 as u32 key we would need to put a dependcy on ematch
> && em_u32 for cls_u32.
> 

I think that you should kill this em_u32 idea if it works only with u32.

> > Above you are trying to insert off2 into the info (what i said i didnt
> > like) - how are you going to achieve the same with a standalone en_u32
> > from say you basic classifier?
> 
> I won't and it's not necessary, one can use u32 if he requires the
> nexthdr capabilities or otherwise use em_cmp support the skb layers.
> (Which i know is not perfect since the pointers to those layers are
> not provided all the time).

Why not just have a check to see if it is native match then not to call
up any ematch executing code. Have the native match maybe be of kind 0.
Have the return code for ematch lookup return something that indicates
that you need to match using local u32 instead of ematch.

cheers,
jamal 
