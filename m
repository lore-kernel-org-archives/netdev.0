From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: RST business
Date: Thu, 22 Apr 2004 16:38:34 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082617714.9967.45.camel@andromache>
References: <40875F2F.7010204@swapped.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Pankratov <ap@swapped.cc>
In-Reply-To: <40875F2F.7010204@swapped.cc>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-04-22 at 15:29, Alex Pankratov wrote:
> Looking at the hype around 'TCP vulnerability'

We're seeing the results of that hype.  Lots of
peers ringing the NOC to urgently arrange TCP MD5
authentication of their BGP sessions.  It looks
like lots of managers have read the press and
issued directives.

Which is ironic, as we're pretty insistent about
configuring MD5 authentication, and so the peer has
in the past explicitly requested that we not run BGP
authentication.  In the past we've assumed that
those were Linux peers, but apparently they were just
slack.

BGP is particularly vulnerable as they are long-lived
(some sessions here are longer than 400 days, so there can
be lots of attempts) and the interpretation of RST is dramatic
(remove routes learned from that neighbour).

Now if only they would release a Security Advisory
about the risks of unauthenticated OSPF and get the
same level of response :-)


> Comments ?

The essential problem is that RST is the generic
way of recovering from a failure condition in the TCP
state machine.

So trusting that the values in the remainder of
the TCP header are correct is a large leap of
faith (perhaps they got trod on by an errant
pointer, and perhaps the resulting out-of-range
value is why the other end sent us the RST).

If you choose to ignore a RST, and the RST is valid,
then you need to ensure that the TCP connection will
always time out (thus issuing its own RST).

You can expect, but not be assured of, a RST for
each subsequent packet sent on that connection
(and maybe that's a cheap way of checking if the
original RST is valid, hmmm).

Best wishes,
Glen
