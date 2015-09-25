From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/4] switchdev: push bridge attributes down
Date: Thu, 24 Sep 2015 20:47:41 -0700
Message-ID: <20150924204741.697a804b@urahara>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
	<20150924140525.514eac85@urahara>
	<CAE4R7bATAj3JtinF7BjFhR26ViC39BB9AjBEJ7h=4LW0XMyn9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33700 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbbIYDrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 23:47:32 -0400
Received: by pacex6 with SMTP id ex6so92498154pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 20:47:32 -0700 (PDT)
In-Reply-To: <CAE4R7bATAj3JtinF7BjFhR26ViC39BB9AjBEJ7h=4LW0XMyn9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2015 20:25:01 -0700
Scott Feldman <sfeldma@gmail.com> wrote:

> On Thu, Sep 24, 2015 at 2:05 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Thu, 24 Sep 2015 13:59:26 -0700
> > sfeldma@gmail.com wrote:
> >
> >> From: Scott Feldman <sfeldma@gmail.com>
> >>
> >> Push bridge-level attributes down to switchdev drivers.  This patchset
> >> adds the infrastructure and then pushes, as an example, ageing_time attribute
> >> down from bridge to switchdev (rocker) driver.  Add some range-checking
> >> for ageing_time.
> >>
> >> # ip link set dev br0 type bridge ageing_time 1000
> >>
> >> # ip link set dev br0 type bridge ageing_time 999
> >> RTNETLINK answers: Numerical result out of range
> >>
> >> Up until now, switchdev attrs where port-level attrs, so the netdev used in
> >> switchdev_attr_set() would be a switch port or bond of switch ports.  With
> >> bridge-level attrs, the netdev passed to switchdev_attr_set() is the bridge
> >> netdev.  The same recusive algo is used to visit the leaves of the stacked
> >> drivers to set the attr, it's just in this case we start one layer higher in
> >> the stack.  One note is not all ports in the bridge may support setting a
> >> bridge-level attribute, so rather than failing the entire set, we'll skip over
> >> those ports returning -EOPNOTSUPP.
> >
> >
> > Rather than having more in bridge, shouldn't this just be a netlink event?
> 
> You lost me?  Oh, do you mean netdev notifier?  Jiri (privately) had
> suggested that also.

Yes. I meant a netlink notifier so that user or kernel space driver
can track changes. Otherwise you have to add switchdev callbacks for
each parameter.
