From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Route cache performance under stress
Date: 05 Apr 2003 20:17:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1049566629.25170.203.camel@tux.rsn.bth.se>
References: <8765pshpd4.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   bert hubert <ahu@ds9a.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <8765pshpd4.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-04-05 at 18:37, Florian Weimer wrote:

> Netfilter ip_conntrack support might have similar issues, but you
> can't use it in a uncooperative environment anyway, at least in my
> experience.  (Note that there appears to be no way to disable
> connection tracking while the code is in the kernel.)

It's correct that ip_conntrack has similar issues. There's been some
work on the hashalgorithm used but no patch has been made yet.
And yes it doesn't scale well at all (especially on SMP), I'm about to
start working on this a bit. Hopefully I can improve it somewhat.

If you've compiled ip_conntrack into your kernel there's only two ways
to disable it and both needs code-modifications :)

Install a netfilter-module that gets the packets before conntrack and
steal the packets, the downside is that you will bypass the rest of
iptables as well.

Apply a patch from patch-o-matic that adds a NOTRACK target that
instructs conntrack to not look at the packets marked by that target.

-- 
/Martin
