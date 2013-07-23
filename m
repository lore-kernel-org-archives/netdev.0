From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: TUN/TAP: tap driver reports bogus interface speed in ethtool
 operations
Date: Tue, 23 Jul 2013 08:56:11 -0700
Message-ID: <20130723085611.0c77c314@nehalam.linuxnetplumber.net>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de>
	<5192BDD6.6060703@qti.qualcomm.com>
	<3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de>
	<48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de>
	<51E5BE27.3060207@qti.qualcomm.com>
	<E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
	<51EEA5ED.6080404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Max Krasnyansky <maxk@qti.qualcomm.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49019 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180Ab3GWP4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:56:14 -0400
Received: by mail-pb0-f53.google.com with SMTP id xb12so8619809pbc.12
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 08:56:14 -0700 (PDT)
In-Reply-To: <51EEA5ED.6080404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Jul 2013 08:49:01 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> On 07/23/2013 06:32 AM, Helmut Grohne wrote:
> >
> > On 16.07.2013, at 23:41, Max Krasnyansky <maxk@qti.qualcomm.com> wrote:
> >> The patch looks fine to me (must admit that I only glanced at it). Please send it to the netdev
> >> mailing list netdev@vger.kernel.org, if you have't already done so.
> >> CC David Miller <davem@davemloft.net> and me.
> >
> > Doing that. Now summarizing the issue for the new recipients:
> >
> > Problem:
> >
> > When querying a tap device for its speed using ethtool the tun driver reports a speed
> > of SPEED_10. This number is hard coded into the driver. Nowadays virtual network devices
> > can go way faster than that. When doing automatic bandwidth monitoring based on the
> > speed reported by ethtool, tap devices tend to come up as false positives. Arguably the
> > hard coded speed is wrong.
> >
> > Proposed solution:
> >
> > To that end I propose supporting the ETHTOOL_SSET command in addition to the already
> > supported ETHTOOL_GSET. It would deny setting any setting except for the bandwidth
> > where it would allow arbitrary values. You can find this patch attached.
> >
> > With this patch an administrator can increase the reported speed for tap devices and
> > keep using automatic detection of interface speeds.
> >
> > Workarounds:
> >
> > Using ethtool a detection utility can determine the driver for an interface. If the
> > driver matches the string "tun", the reported speed should not be used.
> >
> > Helmut
> >
> 
> I like the idea of being able to set the reported speed for a tun/tap 
> interface.
> 
> rick jones

I have hack patch to allow overwriting speed, info, and statistics that is part
of how we use TUN as dummy devices. How far do you think makes sense?
