From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Wed, 20 Aug 2003 01:15:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820011540.27ba635c.skraw@ithnet.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB60@post.pc.aspectgroup.co.uk>
	<20030819151137.3d6e78f2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: richard@aspectgroup.co.uk, alan@lxorguk.ukuu.org.uk, willy@w.ods.org,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819151137.3d6e78f2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 15:11:37 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 19 Aug 2003 23:12:38 +0100
> Richard Underwood <richard@aspectgroup.co.uk> wrote:
> 
> > 	I'm certain that Cisco (for example) won't change their ways.
> 
> I don't believe this.
> 
> In cases where we've been able to show their devices to
> be faulty, they've fixed their kit.  Go check out what
> happened wrt. the ECN issues their firewall products had.

Yes, but you failed to explain their fault in this discussed issue so far. 
Still there is no good explanation for what can be broken if setting the source
ip of an arp request with the interface ip instead of the originating ip (iff
localhost).
According to your own words:
1) the destination host must not care
2) the source ip is no more visible if the request succeeds and a corresponding
entry in the table is made. So originating host has no chance to find out what
it was later on.

Who else should care? 

This discussion could btw have ended months ago (it is coming up now and then)
if a _simple_ way was implemented (like proc-setting) to switch between the two
possibilities.
I always thought we are doing a consensus project here. 
I guess it would be utmost simple to create a patch that implements something
like:

echo > /proc/sys/net/ethX/idontknowwhat 0   (current default behaviour)
echo > /proc/sys/net/ethX/idontknowwhat 1   (source ip of arp request following
the interface)
echo > /proc/sys/net/ethX/idontknowwhat 2   (don't answer arps on this
interface)

It's _simple_ for the user and contains every piece we talked about so far.
Shoot me for not being member of any religion.

Regards,
Stephan
