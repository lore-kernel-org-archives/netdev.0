From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: bcm_sf2: CFP support
Date: Fri, 27 Jan 2017 13:58:11 -0800
Message-ID: <be2a5c66-190a-1d10-16a0-22d1b96ef1c9@gmail.com>
References: <20170127210516.16704-1-f.fainelli@gmail.com>
 <CAFXsbZohZy3ybi6Pe5hryGfuBPnstUAQpB0HM4++XFmwbYi+3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32931 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbdA0WFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:05:39 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so19240834pfg.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 14:05:39 -0800 (PST)
In-Reply-To: <CAFXsbZohZy3ybi6Pe5hryGfuBPnstUAQpB0HM4++XFmwbYi+3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

On 01/27/2017 01:24 PM, Chris Healy wrote:
> Hi Florian,
> 
> In saying the below, I may just be showing my naivety but here goes:
> 
> If I understand this correctly, what you are using is similar to the
> TCAM hardware present in the newer Marvell switches.  I think Pablo is
> doing some work with nftables and HW offload using TCAM HW.  Is there
> overlap here?  It seems that one or the other API should be used but
> not both.

Well, the problem is that there is overlap with 3 different unrelated
subsystems accessing the same HW here: tc, ethtool, and netfilter, all
(two at least) with different ways of formatting input parameters, as I
pointed out a while back in this thread:
https://www.mail-archive.com/netdev@vger.kernel.org/msg126321.html

My angle on this submission is the following, purely based on pragmatism:

- I have real users behind this feature who are currently very happy
with how this works using ethtool, switching them to netlink, tc,
netfilter is not trivial, but could be done in the long run, not just
now. At the very least, this serves as reference code for people who are
curious to see how Broadcom's CFP works

- cls_flower was looked at, it is missing a critical feature IMHO which
is the ability to specify a rule index, and the amount of code necessary
to validate input parameters is just totally insane, just like the fact
that there is not a common intermediate input representation (ala
ethtool_rx_flow_spec) makes it impractical

- I have heard about the work Pablo is doing, but until it is publicly
submitted and reviewed, it's hard to project what it is going to look like

Thanks!
