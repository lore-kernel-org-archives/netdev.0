From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Tue, 4 Jan 2005 13:27:38 +0100
Message-ID: <20050104122738.GG26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <1104812028.1085.50.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104812028.1085.50.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104812028.1085.50.camel@jzny.localdomain> 2005-01-03 23:13
> On Mon, 2005-01-03 at 07:56, Thomas Graf wrote:
> > Patch 4: Basic Classifier
> 
> Very inefficient, but serves the purpose of an example.
> [Even if you go as basic a hash as fw classifier you will do better]

Might be worth to mention the motivation for this. fw and u32
will definitely perform much better on complex setups but
many do not use u32 hashing not to mention even understand it
or have large nfmark -> classid fw maps.

Many use u32 to match simple stuff as port numbers, dscp values
or ip subnet addresses and create a new filter for every port/dscp
value and for every address. Some even use temporary classes to
emulate logic relations and this gets really slow. I have to get
numbers first but a single basic filter with ORed matches is probably
faster than a separate u32 filter for every case. Sure, once u32
has ematch support it gets better and the hashing shouldn't have
too much influence even if it's unused.. We can see what to do once
u32 can handle ematches.
