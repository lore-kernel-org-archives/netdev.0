From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] Vegas and tcp parameters per route
Date: Mon, 15 Mar 2004 13:37:08 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040315133708.08f6b900.davem@redhat.com>
References: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
	<1079160064.11606.15.camel@viivi>
	<20040315092018.1e843d83@dell_ss3.pdx.osdl.net>
	<20040315132214.4d9b5347.davem@redhat.com>
	<20040315133034.487caee1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pasi.sarolahti@iki.fi, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040315133034.487caee1@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 13:30:34 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> > How do you propose to support some kind of "global enable" for features.
> 
> The easiest way to do that is to initialize each TP with features from
> sysctl when created.

Right.

> > I think sysctl's support this quite well.  The test for the feature
> > becomes "sysctl || route_attribute".
> 
> That is what the next version does for FRTO.

OK, but do not limit it to FRTO, I think all TCP features should
be handle'able this way.

Actually, this is a problem with using an RTAX_* that is a bitmask
or single binary.  You need a "don't care" value, and thus effectively
a trinary route entry state to do this properly.  Right?

In this way, you have a global default, but you can also FORCE something
off per-route.  People can work-around ECN-fux0red sites without obviating
ECN completely.

Or perhaps you can come up with another method by which to achieve this?

> Okay, what about WESTWOOD?
 ...
> What about tcp_westwood which is new?

Just don't change sysctl numbers, even we keep them perfectly sync'd between
2.6.x and 2.4.x sources.
