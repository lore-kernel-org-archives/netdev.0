From: James Ketrenos <jketreno@linux.jf.intel.com>
Subject: Re: wireless-2.6 queue opened
Date: Thu, 03 Jun 2004 19:12:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BFBE56.8030005@linux.jf.intel.com>
References: <40BE9ED8.9020505@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40BE9ED8.9020505@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I thought I had replied to this, but I don't see it in my sent, drafts, 
or on the list... so, I'll recompose and send again.

Jeff Garzik wrote:

> It's high time that Linux get a serious effort going on a generic 
> 802.11 stack, as it seems we are in danger of having every new 
> wireless driver invent one if we do not.

Agreed.

> Given that there are at least 3 complete wireless stacks (or 
> thereabouts) floating about for Linux, I picked one that I felt had 
> the best chance of being _evolved_ into a nice, clean, generic 
> wireless stack:  HostAP.

This is the path that ipw2100 has been following; we have taken a 
snapshot of the Host AP code and have generalized the Tx/Rx stacks to 
remove all HW specific fields and structures so we can use them for the 
ipw2100 and (eventually) the ipw2200 project. 

We currently have a HW independent stack that should work for any 
underlying card that can Tx/Rx 802.11 data frames.  This stack is based 
on Host AP 0.1.3 (Pedro Ramalhais has since written a patch for ipw2100 
that will update it to using the Host AP CVS)

The stack we have is not as complete as the original Host AP project -- 
portions of the code (specifically those aspects which I can't test or 
leverage w/ the HW I have) have been wrapped in #ifdef/#endif blocks 
(pretty much everything dealing with master mode).

As we've been trying to track down some ipw2100 project defects we've 
been liberal in throwing some ipw2100 specific checks into the 
ieee80211_* files, but those are easily removed.  Also a result of that 
defect tracking there is some code in those files that just needs to be 
cleaned up/removed.

> My general hope (plan?) is that generic wireless code can be arrived 
> at without horribly intrusive changes that require a 2.7 kernel. 
> wireless-2.6 is targetted for eventual merging, but it won't be 
> submitted anytime soon.

Performance optimizations for wireless may be a bit more intrusive, but 
are not required (AFAIK) to get a generic stack with performance and 
features equivelant to what is currently enabled by the various drivers 
available.

<snip>

> BTW to Intel Centrino folks -- I would like to merge the current (open 
> source) Centrino driver into wireless-2.6 as well, to get it more 
> exposure, and also to ensure that it uses whatever generic 802.11 code 
> happens to appear...

I would like to get a couple stability issues resolved before we 
incorporate the ipw2100 driver into the wireless-2.6 set.

For those that are curious, the current work plan for the ipw2100 is 
(roughly):

0) Fix fragmentation in the current ieee80211_* Tx/Rx stack
1) Generalize the management frame handling (as much as is currently 
required) into ieee80211_*
2) Extract the ieee80211_* code so that it can be compiled into the 
kernel separate from ipw2100 (either as a module or static)
3) Create a patchset for the wireless extension interface to support 
what's needed to configure algos and keys (based in part on what is done 
in Host AP and other drivers).  Also provide a patchset for the user 
space tools.  Hopefully that will kick off lots of discussion :)

During all of the above we will also be working to fix existing 
stability and feature issues.  Main issues here deal with a data 
corruption issue during C3 processor transitions as well as random 
stalling of SSL connections.

James
