From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 18 Jan 2005 16:23:26 +0100
Message-ID: <20050118152326.GB11798@xi.wantstofly.org>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050118145830.GS26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2005 at 03:58:30PM +0100, Thomas Graf wrote:

> > u32> ?
> > gives me help
> > u32> context
> > filter dev lo parent ffff: protocol ip prio 10
> > u32> add 
> > u32> match ip src 10.0.0.21/32 flowid 1:16 action drop
> > u32> match ip src 0/0 flowid 1:16 action ok
> > u32> commit
> > filters submitted ..
> 
> What do you if there is an error? To what kind of context do you
> go? Let's say the kernel reports -EINVAL.

You just refuse the commit and stay where you are:

buytenh@asd-tc2-m20core1> configure exclusive
Entering configuration mode

[edit]
buytenh@asd-tc2-m20core1# edit policy-options policy-statement test 

[edit policy-options policy-statement test]
buytenh@asd-tc2-m20core1# set from prefix-list test 

[edit policy-options policy-statement test]
buytenh@asd-tc2-m20core1# set then accept 

[edit policy-options policy-statement test]
buytenh@asd-tc2-m20core1# show 
from {
    prefix-list test;
}
then accept;

[edit policy-options policy-statement test]
buytenh@asd-tc2-m20core1# commit 
[edit]
  'policy-options'
    Policy error: test prefix-list referenced but not defined
error: configuration check-out failed

[edit policy-options policy-statement test]
buytenh@asd-tc2-m20core1# top 

[edit]
buytenh@asd-tc2-m20core1# rollback 
load complete

[edit]
buytenh@asd-tc2-m20core1# 
