From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Tue, 4 Jan 2005 14:41:26 +0100
Message-ID: <20050104134126.GJ26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <1104812028.1085.50.camel@jzny.localdomain> <20050104122738.GG26856@postel.suug.ch> <1104844935.1085.103.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104844935.1085.103.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104844935.1085.103.camel@jzny.localdomain> 2005-01-04 08:22
> On Tue, 2005-01-04 at 07:27, Thomas Graf wrote:
> > Many use u32 to match simple stuff as port numbers, dscp values
> > or ip subnet addresses and create a new filter for every port/dscp
> > value and for every address. Some even use temporary classes to
> > emulate logic relations and this gets really slow. I have to get
> > numbers first but a single basic filter with ORed matches is probably
> > faster than a separate u32 filter for every case.
> 
> I am pretty sure someone who knows u32 well can outperform you (in the
> scenarios where u32 works using AND etc).
> Start hitting 50K rules then lets talk ;->

Sure but I'd call a filter with 50K ANDed rules an unlikely scenario ;->
In most cases logic will beat brute force. I used to have a u32 setup
with 4K matches and hashing, it was not only error prone but could be
replaced with 12 egp filters gaining 90kpps. Why's that? Simply because
it was easier to optimize the logic behind it. egp itself is terribly
slow compared to u32.

> If your intent is to write an ematch holder, then it would be worth to
> at least go as far as making it some basic hash - as basic as fw does;
> where collision leads toa linked list. If it is just to show an example,
> then it is fine.

Using what key? We have no knowledge about what the ematches want to
see or not.
