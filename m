From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 11:51:50 -0500
Message-ID: <1104252710.1090.171.camel@jzny.localdomain>
References: <200412270715.iBR7Fffe026855@hera.kernel.org>
	 <20041227121658.GI7884@postel.suug.ch>
	 <1104240053.1100.53.camel@jzny.localdomain>
	 <20041228134022.GA32419@postel.suug.ch>
	 <1104242397.1090.94.camel@jzny.localdomain>
	 <20041228161117.GD32419@postel.suug.ch>
	 <1104251817.1090.164.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1104251817.1090.164.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 11:36, jamal wrote:

I have to go out for a few hours, for completion sake:
- initialization happens like you said with extended matches TLV which
result in building one of those extended match datastruct bound on the
filter. The binding part is easy, the hard part is how you interleaf u32
matches for example vs indev. 

** Also i see your point that changing all the classifiers is painful,
but doing it this once so the next written classifier is easy is worth
the effort in my opinion.

cheers,
jamal

> Heres another approach:
> The classifier is blind while executing those actions.
> Data that needs to be embeded within the classifier is:
> struct {extmatch type:extmatch void_data}.
> extmatch_classify(extmatchdatastruct,skb) is a generic call which does a
> lookup on the type and calls the proper callback. Callbacks return
> standard classifier ret codes.
> So an indev matcher will take the skb and compare against the indev data
> stored in struct->void_data.
> Only other call i can see needed is a registration function. extended
> matchers register a callback and type.
> user space stuff is easy.
> Now with above i dont see how to fit your logical experssions - but its
> a simple change and fits the requirement of writting the one page
> extended matcher. The same thought could be extended to actions.
> Sounds too easy unless i am intoxicated with the double-doubles i have
> been conmsuming last few hours;->
> 
> thoughts?
> 
> cheers,
> jamal
> 
> 
> 
> 
> 
