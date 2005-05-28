From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Sat, 28 May 2005 07:59:41 -0400
Message-ID: <1117281581.6251.68.camel@localhost.localdomain>
References: <20050527224725.GG15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527224725.GG15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-28-05 at 00:47 +0200, Thomas Graf wrote:
> Dave, I'm going through another RFC round to hopefully get
> some comments on the notes below.
> 
> I'm not yet satistifed with the core infrastructure wrt to
> non-linear data, especially for complex cases such as non
> linear skbs. The current way can be easly described as:
> 
> search_occurrance()
>   search-algorithm()
>     while get-next-segment()
>       process-segment()
> 

I dont have  opinions on this since you and Pablo seem to agree on it.
What I remember is that libssearch (or whatever that thing Harald was
looking at) did it differently (callback invoked and it return a code
which said to continue or not).
Also the design should (I think you do already, just double checking) -
should be wary of optimizing for a specific algorithmn; i see you have
KMP but not Boyer-Moore for example and i am not sure what the
repurcassions of above approach are etc etc.

> So basically we save the state of the segment fetching
> instead of saving the state of the search algorithm which
> would be way too complex for things like regular expression
> string matching.
> 

Can you explain this a little more. Didnt quiet understand.
If you are going across skbs, dont you need to save state?

> In the case of non linear skbs this would lead to:
> 


I think the best approach would be to first linearize then search. 
On the egress side this would mean annoying things like no TSO or what
was posted yesterday USO etc. Same thing with ingress, but i suspect
other than the netiron NIC we probably wont be seeing much of non-linear
skbs on the ingress. 
On ingress as well you are also better off to assemble fragments first
on that side before doing text searches. 
Perhaps implementing an action like the one used by openbsd to
"normalize" packets before a string match.
i.e 
classifier (pkt header) --> normalize --> classifier(string match)-> ?

Infact one could argue that if you are to scan a virus you may need
to assemble more than one skb on ingress (essentially a message).

The only other comment i have is on the patch you called naive regexp;
I think you should probably call it something else instead of regexp
since you invented it.

cheers,
jamal
