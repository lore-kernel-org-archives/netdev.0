From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 11:40:25 -0500
Message-ID: <1107189625.1076.77.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <20050131135810.GC31837@postel.suug.ch>
	 <1107181169.7840.184.camel@jzny.localdomain>
	 <20050131151532.GE31837@postel.suug.ch>
	 <1107186044.1076.11.camel@jzny.localdomain>
	 <20050131155929.GF31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131155929.GF31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 10:59, Thomas Graf wrote:
> > My experience is that you end up dropping no more than a packet in a
> > burst with policing before TCP adjusts. Also depending on the gap
> > between bursts, that may be the only packet you drop altogether.
> > In long flows such as file transfers, avergae of one packet ever gets
> > dropped.
> 
> I mostly agree but not completely. It's definitely true that most of
> the problems I'm fighting today are causes by the attempt to be too
> perfect in calculating. Going a step backwards solves most of the
> problems and probably works just fine for most cases. One of the main
> problem I'm facing here are big file transfers on low latency links with
> modified ip stacks to allow for a "faster" slow start (those are the
> reason why I'm trying to do this). An attempt to drop only a few
> packets results in a stronger incremenal growth. I'm not quite sure
> why that happens yet but a more aggresive policing stategy helped a
> lot. I agree that if we plan to put something like this into mainline
> those problem domains should be separated to not overcomlicate the
> whole thing.
> 

Would be interesting to combine policing and random dropping to see 
what happens. 
I think this is something you should be able to find a student to abuse
so they can write a paper ;-> Probably Linux may not even be the right
place to do it to start with - rather simulations until you get it right
then code it into Linux.

> Sounds good. We'll need to address this anyway, the classifiers rely
> on the ip header being valid which is no longer assured.

true - i was thinking of restoring stateless NAT at this level as well.
So csum would be needed. The csum could be programmed to either
validate only or recompute; those are the only two arguements to it that
i could think of. I suppose first thing is to put out the eaction patch
then add this action. I will try to sneak in some time this week and
write the eaction.

> > Ok, I think both approaches are correct. ematch does the check/get
> > essentially; and action will create the set/tracking if needed.
> > For the example i gave, you are absolutely correct, ematch is
> > sufficient.
> 
> Right, so we can do something like the meta ematch/action split. What
> attributes to you intend to be modifieable? 

Essentially on ingress create state; i have to find my notes to give you
precise answer. But one of the parameters was to select the level of
state tracking (such as "track IP only" - not sure how doable that is
with contrack)
 
> A neat thing would be
> to overwrite the state and thus assign a packet to another connection
> which could be used to reimplement fast nat together with pedit.

Stateless NAT doesnt really need contracking. pedit (taught to speak
english) + eaction csum should do it.

cheers,
jamal
