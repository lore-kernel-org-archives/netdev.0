From: Pavel Roskin <proski@gnu.org>
Subject: Re: linux-wireless mailing list
Date: Thu, 04 Mar 2004 02:08:08 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.58.0403040100300.4248@portland.hansa.lan>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com>
 <20040303233343.GA14803@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <20040303233343.GA14803@bougret.hpl.hp.com>
To: jt@hpl.hp.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Mar 2004, Jean Tourrilhes wrote:

> On Wed, Mar 03, 2004 at 05:28:30PM -0500, Pavel Roskin wrote:
> > Hello!
> >
> > I believe the developers of Linux wireless drivers need a separate mailing
> > list, preferably called linux-wireless at vger.kernel.org.  I don't expect
> > it to have heavy traffic, but there should be a definitive forum for
> > discussing issues common for wireless drivers on Linux.
>
[snip]
> 	Why does this matter ? If those driver maintainers don't feel
> part of the Kernel, they probably won't feel part of the "Linux
> wireless driver" group that you are trying to create.
> 	Those maintainers are already busy with bug reports and
> users. They would need a good incentive too coordinate such
> activities across drivers.

Avoiding more work later is a pretty good incentive.  If the driver turns
out to be inconsistent with others, it will have to be changed, perhaps
retaining the original code for backward compatibility.

> 	Fortunately, those maintainers know about the common good and
> always take the path of least resistance. If someone provide the
> infrastructure, they will eventually buy into it. Actually, the new
> developpers are more likely to use it than those who already have
> working solutions.
> 	Look at the firmware download support. Manuel did a good job
> of talking with the various driver authors and come up with a useful
> solution, and it's a great success.

Firmware download support was a major achievement, and it was not limited
to networking, let alone wireless networking.  Manuel did a great job.

There are often much smaller issues, often so minor that I don't want to
bother you personally.  Today's example - when the card connects to an
access point and changes its ESSID (because the desired ESSID is "any"),
should the driver send an wireless event for BSSID only or also for ESSID?

I know, you are a great guy and you will answer me, but I don't want to be
the fifth person to ask you that in private.  I don't want to check
drivers for the hardware I don't have trying to understand what they would
do in this situation.

> 	Coming back to your point. It seems to me that what we need is
> motivated people willing to push specific cross-driver activities and
> coordinate those with the driver maintainers.

It would be natural for userspace developers and distribution maintainers
to promote specific interfaces and standards, but it would be too much to
expect them to negotiate with different driver developers trying to
explain the same thing over an over again.

It would be easier for them to post to linux-wireless and see the
discussion.  If I as a driver (co-)maintainer don't read that list, the
decision will be made without me, and then (kismet|airsnort|xsupplicant)
maintainers with came to harass me so I implement what other _driver_
developers have agreed to.  Seems like a good incentive to pay attention
:-)

> 	The mailing list you propose may help those people to acheive
> their goal. But, without such people, it probably won't take off,
> because driver maintainers are just too busy.
> 	But, of course, I would be happy to be wrong ;-)

Having a list will help less motivated and more busy people reach the
audience they want to reach and achieve the goals they want to achieve.
I hope so.

> > I expect following topics to be discussed:
> >
> > Wireless Extensions.  I highly respect Jean Tourrilhes who is doing this
> > work.  I believe that driver and userspace developers should use this
> > forum to discuss their needs and to provide feedback to Jean.
>
> 	I can tell you already : WPA.

Yes.

Also, since Wireless Extensions define monitor mode (as one of the modes),
I would expect to see a definition of what it is, including frame format.
Maybe I want too much.

> > Handling of 802.11 frames.  We may need common code to convert 802.11
> > frames to 802.3 and possibly other standards.  Maybe some standards for
> > 802.11 encapsulation and bridging could be discussed as well.
>
> 	Yes, this is a sore point. Rather than starting from scratch I
> believe you should start from code in an existing driver (such as
> HostAP or MadWifi).
> 	Note that there are two separate parts, support of 802.2 (all
> the SNAP encapsualtion business), which is also useful for 802.3
> networks, and support of 802.11 framing. I believe that Arnaldo was
> working on 802.2 support (as part of IPX stuff).

That's the part I don't know well.  I feel uneasy that David Gibson tries
to invent something in the Orinoco driver, and I'm one of very few people
who can comment early on those efforts, yet I know too little about the
networking site of things to provide useful feedback.  If the
linux-wireless list existed, I would have some assurance that we are not
doing something that's not going to be accepted by other drivers.

> 	Actually, you remind me that I should ask Jouni to push his
> driver in the kernel.

I believe it can happen after RC4 goes to the kernel and HostAP uses
crypto API (optionally in the standalone version to keep Linux 2.4
compatibility).

> > Sniffing.  We need a common standard how to pass raw frames and additional
> > information to the userspace.  There are several de facto standards, but
> > the lack of communication between developers makes those standards less
> > useful.  For example, Prism2 headers were meant as highly extensible, but
> > libpcap expects them to be of fixed size.  It's an obvious failure to
> > communicate the intentions of the standard.
>
> 	Software never get it right on the first try. That's a bug
> report on libpcap. If you break libpcap, they will notice soon enough.

I don't want somebody to tell me that Orinoco does it wrong because all
other drivers use 144 bytes per header.  If it happens, I want to show a
link to a thread where it was discussed.  Sure, it's not a as good as a
written standard, but if it's the official linux-wireless list, interested
persons are supposed to comment before it's to late.

Without the list, I'll have to ask linux-wlan-ng team to write a standard,
then go to libpcap guys to persuade them to implement the standard as
described by the inventors of Prism2 headers.

> > Encryption.  There are wireless specific encryption issues.  Host based
> > WEP support needs RC4 cipher in the kernel.  There's not much to discuss
> > here, but the lack of RC4 in the kernel may indicate that Linux wireless
> > developers are not acting together to make it happen.  The patch does
> > exist.
>
> 	I've never seen this patch. Was it sent to the Crypto guys ?

http://sourceforge.net/mailarchive/message.php?msg_id=7298902

I'll ask Jon Oberheide where he sent it.

> > I believe linux-net@vger.kernel.org is the right place to ask because
> > Wireless almost inevitably assumes networking.  I'll appreciate if
> > somebody with enough weight in the kernel development supports this issue.
> > Or at least please let me know where else I should ask and whose support I
> > need to have.
>
> 	Don't get me wrong, I'm supportive, I just wanted to set a bit
> of context. I can't host mailing lists at HP, and SourceForge is not
> really reliable.

I posted this proposal because I felt that many people think this way and
somebody should post it.

-- 
Regards,
Pavel Roskin
