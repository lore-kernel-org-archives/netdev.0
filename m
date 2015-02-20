From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Thu, 19 Feb 2015 21:35:00 -0500
Message-ID: <20150220023500.GK580@gospo.home.greyhouse.net>
References: <20150213212830.GA29912@electric-eye.fr.zoreil.com>
 <54E1568D.5000100@windriver.com>
 <20150216120345.4dfd9950@uryu.home.lan>
 <20150219.154041.184372158520813993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, Yanjun.Zhu@windriver.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org, mst@redhat.com,
	jasowang@redhat.com, viro@zeniv.linux.org.uk,
	sergei.shtylyov@cogentembedded.com, jonathon.reinhart@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:47529 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbBTCfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 21:35:04 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so10135230qab.2
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 18:35:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150219.154041.184372158520813993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 03:40:41PM -0500, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 16 Feb 2015 12:03:45 -0500
> 
> > I would like to propose this is as a more complete alternative.
> > 
> > From: Stephen Hemminger <stephen@networkpluber.org>
> > Subject: [PATCH] tun: support overriding ethtool information
> > 
> > Extensions to allow masqurade of ethtool info and device statistics.
> > This is useful to provide correct information to SNMP and OSPF routing
> > daemons when doing hw/sw offload of network device.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> We need a consistent policy regarding link attributes of encapsulating
> "software" devices.

I think this is a great point and though I like Stephen's patch due to
how useful it would be to me, I had some concerns about whether or not
others would accept it without a bit more of 'a plan' for functions like
this.

> 
> I see three realistic options:
> 
> 1) Create a link state indication which means "I am a software device,
>    so I don't really have a link state in the traditional sense"
> 
> 2) Don't implement the link set/get operations at all on software
>    devices.
> 
>    People can use ETHTOOL_GLINK to see if the thing is "up"
> 
> 3) Propagate the ultimate physical transport parameters into what
>    the software device advertises.
> 
> It's important to carefully pick one of these, and consistently apply
> it to all of our software devices.
> 
> I don't want TUN doing one thing, ipv4 tunnels doing another, etc.

I would prefer option #3 as it relates to the ability to transport
offload statistics and parameters to software devices.  This could be
useful for hardware with some form of offload vxlan/gre/etc that may be
backed by hardare statistics (a callback to the upper device's ndo op
could be made by the native hardware driver) or any other device without
a proper in-kernel driver like a userspace user of tuntap that might be
backed by something like OpenVPN.

That might help provide some more detailed, ethtool-like statistics in
the format that is more easily readable by common monitoring tools
without the need to have those applications look at anything except an
ethtool/kernel interface.
