From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 12:03:05 -0500
Message-ID: <1109005385.1074.68.camel@jzny.localdomain>
References: <20050220230713.GA62354@muc.de>
	 <200502210332.j1L3WkDD014744@guinness.s2io.com>
	 <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch>
	 <1108994621.1089.158.camel@jzny.localdomain>
	 <20050221141714.GV31837@postel.suug.ch>
	 <1108996313.1090.178.camel@jzny.localdomain>
	 <20050221153443.GW31837@postel.suug.ch>
	 <1109000925.1076.3.camel@jzny.localdomain>
	 <20050221164006.GY31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050221164006.GY31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-21 at 11:40, Thomas Graf wrote:
> * jamal <1109000925.1076.3.camel@jzny.localdomain> 2005-02-21 10:48
> > On Mon, 2005-02-21 at 10:34, Thomas Graf wrote:
> > > Make sense but we probably have multiple packets in the stack if qdiscs are
> > > involved. 
> > 
> > No - thats the problem. Theres always no more than one packet i.e only
> > packet in flight except in the case of some hardware - which i pointed
> > out as problematic in my SUCON presentation.
> 
> I read your slides again but I guess I'm missing the information you
> provided in your speech. One of the disadvantages of organizing a
> conference is that one can't listen to the speeches. ;->
> 

Most of this came after SUCON actually after the BSD folks claimed to be
doing 1Mpps forwarding (only to find out they used CSA later).
Look at the case where we have 32 bit bus in those slides; in that
scenario we do see an improvement with batching (but really for the
wrong reasons). The next piece of hardware we see infact a degradation
in perfomance.


> So basically you're telling me that it doesn't make a difference for a
> full qdisc to dequeue in single steps or in batches?

I said in some cases it does make sense (as in the case of 32 bit bus
above) in some it doesnt (as in the case of  most xeon boards, fast CPU,
fast PCI-X). 
Any solution should be where things work all the time or most of the
time and are not very hardware specific. If we can hit 95% of the cases,
then it would make sense to do submit such the patch. Otherwise
it was a good exercise for me, but useless in general. I do plan to work
on trying out some heuristics like discovering a few things (such as CPU
speed, runtime congestion etc) before activating the batching code.
Wont have time for at least 1 month.

cheers,
jamal
