From: Alex Pankratov <ap@swapped.cc>
Subject: Re: ENOBUFS and dev_queue_xmit()
Date: Tue, 15 Jun 2004 08:39:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CF182F.4060401@swapped.cc>
References: <40CE818C.2090906@swapped.cc> <1087304060.1043.72.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1087304060.1043.72.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> On Tue, 2004-06-15 at 00:56, Alex Pankratov wrote:
> 
>>I've been poking around rather weird problem today where send()

[snip]

>>meaning that the device's queue was stopped. The comment there
>>implies that only a broken virtual device may end up $here,
> 
> 
> How did you end up there with a real phy device?? Are you trying to
> circumvent the qdisc subsystem? If yes, you are responsible for how
> all this gets handled.

Now that I looked at dev.c code again I ask myself the very same
questions :) I am not circumventing qdisc, at least intentionally,
and I don't do anything fancy with dev->qdisc. It must be a bug
due to some of my changes, ignore the original question. Thanks
for your help.

>>
>>Is this a known (pseudo?) issue ? ENOBUFS makes much more sense
>>in this context. I can certainly check interface status (IFF_UP)
>>on every ENETDOWN to see what's the real cause, but that's kind
>>of ugly.
> 
> Did you mean when no space is left in the ring? Thats different
> from ENOBUFF. If not, not sure i see how a driver xmit path gets
> involved in kmallocing.
> Look at the return code the driver returns. In case of a full ring, it
> should return a busy signal and the top layer will retry later.
> You dont have to worry about any of that if you are running the 
> std linux semantics, of course. I have a feeling you have attempted to
> bypass it otherwise the question becomes: how you even ended in this
> situation. 
> 

I'm pretty sure you're right about breaking the semantics. I'll check
it out, and re-complain if it's not my problem. Thanks again.
