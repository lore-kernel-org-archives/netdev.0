From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Tue, 22 Nov 2011 18:30:03 -0800
Message-ID: <4ECC5AAB.8000605@intel.com>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<1321878007.2291.12.camel@mojatatu>
	<CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<1322012755.2039.36.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322012755.2039.36.camel@mojatatu>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/22/2011 5:45 PM, Jamal Hadi Salim wrote:
> On Tue, 2011-11-22 at 15:11 -0800, Jesse Gross wrote:
> 
> 
>> As you mention, one of the biggest benefits of Open vSwitch is how
>> simple the kernel portions are (it's less than 6000 lines).  
> 
> I said that was the reason _you_ were using to justify things
> and i argue that is not accurate.
> You will be adding more actions and more classification fields to
> the datapath - and  you are going to add them to that monolithic
> "simple" code. And it is going to grow.
> 
> BTW, you  _are using some of the actions_ already (the policer for
> example to do rate control; no disrespect intended but in a terrible
> way). 
> Eventually you will canibalize that in your code because it is "simpler"
> to do that.
> So to be explicit: I dont think this is a good arguement.
> 
>> It's
>> existed as an out-of-tree project for several years now so it's
>> actually fairly mature already and unlikely that there will be a
>> sudden influx of new code over the coming months.  There's already
>> quite a bit of functionality that has been implemented on top of it
>> and it's been mentioned that several other components can be written
>> in terms of it 
> 
> I very much empathize with this point. But that is not a technical
> issue.
> 
>> so I think that it's fairly generic infrastructure that
>> can be used in many ways.  Over time, I think it will result in a net
>> reduction of code in the kernel as the design is heavily focused on
>> delegating work to userspace.
> 
> Both your goal and the Linux qos/filtering/action code is to be be
> modular and move policy control out of the kernel. In our case,
> any of the actions, classifiers, qos schedulers can be experimented 
> with out of tree with zero patch needs and when ready pushed into the
> kernel with zero code changes to the core. So nothing in what we have
> says the policy control sits in the kernel.
> 
>> I would view it as similar in many ways to the recently added team
>> device, which is based on the idea of keeping simple things simple.
> 
> Good analogy, but wrong direction: Bonding is a monolithic christmas
> tree which people kept adding code to because it was "simpler" to do 
> so.
> Your code is heading that way because as openflow progresses or some 
> new thing comes along (I notice capwap) you'll be adding more code for
> more classifiers and more actions and maybe more schedulers and will
> have to replicate things we provide. And they all go into this
> monolithic code because it is "simpler".
> 
> Is there anything we do that makes it hard for you to use the
> infrastructure provided? Is there anything you do that we cant 
> provide via the classifier-action-scheduler infrastructure? 
> If you need help let me know.
> 
> 
> cheers,
> jamal
> 

He is pushing and popping entire tags off 802.1Q for now but
you can easily imagine MPLS tags and all sorts of other things
people will _need_.

Do we want tc and likely the skbedit action to explode into a
packet mangling tool? Would it make sense to plug into ebtables
perhaps with a new family, NFPROTO_OPENFLOW or even on the
existing NFPROTO_BRIDGE.

Although doing it with classifiers and more actions would flush
out that TODO in act_mirred, and get us an mq_ingress among
other things.

.John
