From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 01 Feb 2005 06:49:40 -0500
Message-ID: <1107258578.1095.570.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <41FEB3AE.3090400@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <41FEB3AE.3090400@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 17:39, Andy Furniss wrote:
> Jamal Hadi Salim wrote:

> > 2) Allows for queueing incoming traffic for shaping instead of
> > dropping. I am not aware of any study that shows policing is 
> > worse than shaping in achieving the end goal of rate control.
> 
> I would say the end goal is shaping not just rate control. Shaping 
> meaning different things to different people and ingress shaping being 
> different from egress.

I know for a while the Bart howto was mislabeling the meaning of
policing - not sure about shaping. 
Shaping has a precise definition that involves a queue and a
non-working-conserving scheduler in order to rate control. This doesnt
matter where it happens (egress or ingress). Policing on the other hand
is work conserving etc.

> For me it's from the wrong end of a relativly narrow (512kbit) 
> bottleneck link that has a 600ms fifo at the other end. My aim to 
> sacrifice as little bandwidth as possible while not adding latency 
> bursts for gaming and per user bandwidth allocation (with sharing of 
> unused) and sfq within that for bulk tcp traffic.
>
> If I was shaping LAN traffic, then policers/drops would be OK for me - 
> but for a slow link I think queueing and dropping are better/give more 
> control eg. I get to use sfq which should not drop the one packet a 56k 
> user has managed to send me in the face of lots of incoming from low 
> latency high bandwidth servers.
>
> Even if it's possible I bet few can easily get policers to setup the 
> complex sharing/prioritisations that you can with HTB or HFSC.

sfq has a built in classifier that can efficiently separate those
flows so you can achieve semi-fairness; so its not the shaping perse
that helps, rather you ended up using a clever scheme that can isolate
flows and benefited from shaping as a result; the hashing function
should prove weak when a lot of flows start showing up.
You could write some interesting classifier (as an example steal the one
that sfq has) and achieve the same end results with policing. This would
be easier now with ematches .. 

> > But i wont go back to putting netfilter hooks in the device to satisfy
> > this.  I also dont think its worth it hacking dummy some more to be 
> > aware of say L3 info and play ip rule tricks to achieve this.
> > --> Instead the plan is to have a contrack related action. This action
> > will selectively either query/create contrack state on incoming packets.
> 
> I don't understand exactly what you mean here - for my setup to work I 
> need to see denatted addresses and mark (connbytes - it helps me be 
> extra nasty to multiple simoultaneous connections in slowstart and 
> prioritise browsing over bulk) in prerouting mangle. Of course if I can 
> use netfilter to classify and save into contrack then I could do 
> evrything in netfilter and then use something like connmark to save it 
> per connection.
> 

You may be refering to requirement #3 then? 
In other words what you are doing is best served by knowing the state?
Are pre/post routing sufficient as netfilter hooks for your case?

> > Packets could then be redirected to dummy based on what happens -> eg 
> > on incoming packets; if we find they are of known state we could send to
> > a different queue than one which didnt have existing state. This
> > all however is dependent on whatever rules the admin enters.
> 
> 
> How does the admin enter the rules - netfilter or other?
> 

Just like i showed in that post (It was long - so dont wanna cutnpaste
here).

cheers,
jamal
