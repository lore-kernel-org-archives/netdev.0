From: Gabriel Paues <gabriel@sics.se>
Subject: dst_entry and friends
Date: Mon, 29 Apr 2002 12:14:48 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CCD1D18.F33EAEE8@sics.se>
References: <15561.20004.964497.762468@robur.slu.se>
Reply-To: gabriel@sics.se
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I'm working on my Masters Thesis which aims at making a label switched
environment. I know there are protocols for doing that but I am supposed to do
it at IPv6-level (by altering the IPv6-stack) thus making Linux route on
different criteria than the usual routing table.

This is what i want to do:
If the flowlabel in the IPv6 header is set to some value except zero then skip
the whole routing behaviour and check for the flowlabel in an internal table,
and get the out-device and new flowlabel from that table and send the packet.
otherwise:
Just do as usual

My idea is to use netfilter and in the PRE_ROUTING-hook check the flowlabel for
values other than zero, and set the dst_entry in the skbuff to something with
its input-function to ip6_output. I dont know if I should allocate this
fabricated dst_entry myself or if I should scan the list of already existing
ones. By setting the input-function-pointer to ip6_output i will skip the whole
routing behaviour in a snap. The same goes for the hook LOCAL_OUT where i want
to skip ip6_maybe_reroute function and go directly to ip6_output.

This might sound like a quite destructive concept, but the whole thing is that
my teacher thought those "small hacks"  could be done in notime, whle I have
discovered that thats not the case.

Do you know of any easier way of doing this? And if not, how do I get hold of a
dst_entry when I know what netdevice that should be the output? I have had a
look in rt6_device_match function in route.c and think that it does more or
less what I want to do.

I would be grateful if some Linux Ipv6-implementation guru would read this and
try to understand what I'm trying to do... :-)

Sincerily

Gabriel
