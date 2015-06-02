From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 2 Jun 2015 00:44:59 -0700
Message-ID: <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com> <556D522E.90607@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel@savoirfairelinux.com, Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35519 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbFBHpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 03:45:21 -0400
In-Reply-To: <556D522E.90607@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 1, 2015 at 11:50 PM, Guenter Roeck <linux@roeck-us.net> wrote:

[cut]

> I brought this up before. No idea if my e-mail got lost or what happened.
>
> We use a fid per port, and a fid per bridge group. With VLANs, this is
> completely
> ignored, ahd there is only a single fid per vlan for the entire switch.
>
> Either per-port fids are unnecessary as well, or something is wrong here,
> or I am missing something. Can you explain why we only need a single fid
> per vlan, even if we have multiple bridge groups and the same vlan is
> configured in all of them ?

That brings up an interesting point about having multiple bridges with
the same vlan configured.  I struggled with that problem with rocker
also and I don't have an answer other than "don't do that".  Or,
better put, if you have multiple bridge on the same vlan, just use one
bridge for that vlan.  Otherwise, I don't know how at the device level
to partition the vlan between the bridges.  Maybe that's what Vivien
is facing also?  I can see how this works for software-only bridges,
because they should be isolated from each other and independent.  But
when offloading to a device which sees VLAN XXX global across the
entire switch, I don't see how we can preserve the bridge boundaries.

I hope I'm not misunderstanding the issue here; if I am, I apologize.

-scott
