From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [IPSEC] Too many SADs!
Date: Wed, 23 Mar 2005 13:20:21 +0100
Message-ID: <200503231320.21645.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Frost <sfrost@snowman.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > We had the same problem. Seems to be a limitation of the 
pfkey-implementation 
> > of linux.
> > 
> > racoon and setkey both use the pfkey-interface.
> > 
> > We switched to iproute2 and openswan which both use the 
netfilter-interface. 

Sorry, wanted to say netlink-interface.

> > Therefor they can handle thousands of SAD and SPD rules.
> 

> Well, that's quite interesting.  I didn't realize there were multiple
> interfaces to the IPSEC in Linux.  Additionally, the problem isn't that
> I've got too many policies which end up requiring too many SADs- the
> problem is that SADs are being created above and beyond what's actually
> necessary for my policies, which is a problem.  I'm not entirely sure
> why that's happening either.  At one point a SAD was being added every
> second when there was *already* an apparently current SAD for the
> required policy.  Not good, looks like a bug to me, and I would have
> thought it was a kernel bug but I could be wrong there.

Hmm, we saw this with racoon, too.

I think that linux sometimes can not send pfkey-messages because it can not 
allocate enough memory in that moment. The message get lost and then racoon 
and kernel have different views of the situation. I think the pfkey-protocoll 
is unreliable by design so racoon should handle that.

If you start racoon with no spd-rules and then start to add a lot of them with 
setkey you get a similar behaviour: some of the new rules don't make it to 
racoon and racoon will never learn them. (we tried this as a workaround 
because racoon does not start when more than about 400 spd-rules are already 
set).

That racoon does not start with more then about 400 spd-rules seems to be also 
a problem of the pfkey-implementation: the pfkey-answer to the dump-request 
which racoons does at startup gets to large: the kernel can not allocate 
enough memory.

(and this is the reason setkey can not list the rules, either, so you may use 
it to add more spd-rules it can later list).

> 
> I'm certainly curious about the alternative interface to IPSEC in
> Linux, and especially your claim that it's a 'netfilter' interface.

As mentioned, meant netlink-interface, not netfilter.

> I'll certainly look into that...  What kernel are you using?  What
> version of iproute2 and Openswan?  Do you have to patch the kernel?
> 

iproute2 from debian unstable (20041019-3).

openswan from debian unstable: openswan 2.3.0 (debian version: 2.3.0-2)

>         Stephen
>

Greetings,

Wolfgang Walter
