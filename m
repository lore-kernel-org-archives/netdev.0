From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Thu, 19 Feb 2015 19:41:31 -0500
Message-ID: <20150220004130.GA15087@penelope.isobedori.kobe.vergenet.net>
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
Received: from mail-yh0-f42.google.com ([209.85.213.42]:40622 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbbBTAlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 19:41:37 -0500
Received: by yhot59 with SMTP id t59so1909682yho.7
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 16:41:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150219.154041.184372158520813993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

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

I am wondering if/how you see 3 playing out with e.g. ipv4 tunnels.
It seems to me there may be a consistent underlying device.
