From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 12:06:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087412780.3351.34.camel@sfeldma-mobl2.dsl-verizon.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>
	 <40CF263E.70009@home.nl>
	 <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>
	 <40D08769.3070106@home.nl>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jkmaline@cc.hut.fi, jt@hpl.hp.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gertjan van Wingerde <gwingerde@home.nl>
In-Reply-To: <40D08769.3070106@home.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-16 at 10:46, Gertjan van Wingerde wrote:

> I'm afraid that this isn't enough. I think we have to split up the various settings over
> multiple commands. If we add just two commands (one for GET and one for SET) we have to
> change the binary ioctl-interface every time a new setting arrives (e.g. see how new
> settings will be added due to WPA support. That solution just isn't future-proof.

There is some reserved space at the bottom of the struct to add new
commands.  The question is: how many new commands are needed for the
future?  I think we need to be very careful in keeping the standard
settings for wireless bounded.  In fact, we should take a careful look
at the standard settings already defined and really question their need.

For example, do we really want to burden the user with the decision of
whether they need to set a maximum fragment size?  Or what the
sensitivity threshold should be?  The point is, we need to find the
minimal set of settings to get the job done.

So let's have this discussion first before getting back to the
implementation details.

What is the minimal set of settings to expose to the user[1]?  I would
group them into basic, advanced, and authentication.  Which ones are
read-only?  What's new in the near future?

Once we agree on that set, the implementation falls out.

-scott

[1] By user, I mean someone that's just trying to get their wireless
device to attach to a network, but doesn't know the difference between
11b and 11g or the meaning of RTS.
