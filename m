From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 15 Jul 2004 12:07:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089907622.1027.48.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1089905244.6114.887.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-15 at 11:27, Evgeniy Polyakov wrote:
> On Thu, 2004-07-15 at 18:44, jamal wrote:
> > Evgeniy,
> > 
> > Why do you need to put this stuff in the kernel?
> > This should be implemented just the same way as VRRP was - in user
> > space.
> 
> Hmm...
> Just because i think it works better being implemented in the kernel? :)
> I don't think it is a good answer thought.
> 
> It is faster, it is more flexible, it has access to kernel space...

Yeah, I know ;-> and probably thats what the opnebsd people did.
 
I still think it should live in user space.  This should apply to
anything thats control related because such things tend to be
continoulsy enrichned with features. ARP unfortunately is in there; one
of my pet perpetual projects is to totaly rip it off. Theres already
hooks to deliver to user space today and Alexey has a daemon for it, not
sure how widely used it is.

> > BTW, is there a spec for this protocol or its one of those things where
> > you have to follow Yodas advice?
> 
> Exactly :)
> Here are all links I found:

Thank you. 
I think a better idea would be to implement a sync message
within CARP instead of that pfsync app doing its own thing. Unless i
misread, pfsync seems to be a separate app.
This way more than one app can use it via the CARP daemon
in user space to sync state of their choice (with whatever pfsync does
being one of many). 
This is an example of a rich application and further justification for
it to live in user space.

> I do want this to be in the mainline kernel, but actually I even don't
> think anyone will apply it.
>
> It is too special stuff for generic kernel, it has reserved 112 vrrp
> protocol number and so on...
> So if developers decide not to include or even not to discuss this cruft
> I will not beat myself by my heels. :)
> 
> It just works as expected, it is reliable and simple.
> And it does it's work, so HA people would like it.

It is valuable, just doesnt belong to the kernel.
BTW, i saw some claim that this is patent-free as opposed to VRRP?
I do hope it takes off.  What exactly is the patent issue that was at
stake? I couldnt tell from the song lyrics ;->
One valuable thing that could be done is while still avoiding any patent
issues make it interop with VRRP.

cheers,
jamal
