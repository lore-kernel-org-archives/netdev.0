From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 01 Feb 2005 08:13:33 -0500
Message-ID: <1107263612.1095.598.camel@jzny.localdomain>
References: <20050131135810.GC31837@postel.suug.ch>
	 <1107181169.7840.184.camel@jzny.localdomain>
	 <20050131151532.GE31837@postel.suug.ch>
	 <1107186044.1076.11.camel@jzny.localdomain>
	 <20050131155929.GF31837@postel.suug.ch>
	 <1107189625.1076.77.camel@jzny.localdomain>
	 <20050131181553.GG31837@postel.suug.ch>
	 <1107202715.1075.559.camel@jzny.localdomain>
	 <20050131225328.GI31837@postel.suug.ch>
	 <1107259361.1095.584.camel@jzny.localdomain>
	 <20050201125147.GK31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050201125147.GK31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-02-01 at 07:51, Thomas Graf wrote:
> > Why bother putting extra classifier functionality into a qdisc? 
> > you should be able to rip off the classifier from sfq so you dont depend
> > on it; you can then select one of n queues (eaction meta set class 1:X
> > based on result of sfq classifier - or you can have it set the classids
> > based on resulting hash index) 
> 
> Excellent idea, this would allow for various hash functions to be used
> in a single sfq. We can use skb->tc_index for it so we can easly combine

Let the meta action do that. Just set the skb->tc_classid in my opinion;
recall we can change classid now ..

> it with a underlying dsmark. The hardest part is to find a intuitive
> form to define the hash, it should be possible to for example define
> a hash based on daddr + hproto only completely ignoring saddr. The
> perutrbation must be made optional, sometimes the hash will not produce
> any unwanted collisions (hash based on dscp for example) so modifying it
> wouldn't make sense. We can fork sfq and make a gsfq which takes the
> hash from tc_index and disabled perturbation if it is set to 0.
> Thoughts?

You can let the user define that via tc but have a default;
eg: 
tc dev eth0 add sfq ematch
tc dev eth0 set sfq pertub xxx

match u32 ...
ematch sfq
ematch meta classid 1:2 
eaction meta set tcindex 101
eaction meta set fwmark ..

etc

I have to run, havent looked at the rest of your email - will later.

cheers,
jamal 
