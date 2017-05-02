From: Sylvain Lemieux <slemieux.tyco@gmail.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix mdio bus name when using
 devicetree
Date: Tue, 02 May 2017 10:26:03 -0400
Message-ID: <1493735163.19031.2.camel@gmail.com>
References: <20170501145404.18581-1-slemieux.tyco@gmail.com>
         <20170501152054.GD1285@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35513 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdEBO0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 10:26:11 -0400
Received: by mail-it0-f67.google.com with SMTP id 131so2566057itz.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 07:26:10 -0700 (PDT)
In-Reply-To: <20170501152054.GD1285@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Mon, 2017-05-01 at 17:20 +0200, Andrew Lunn wrote:
> On Mon, May 01, 2017 at 10:54:04AM -0400, Sylvain Lemieux wrote:
> > From: Liam Beguin <lbeguin@tycoint.com>
> > 
> > mv88e6xxx_mdio_register automatically generates mdio buses for each switch
> > discovered in the devicetree. When switch nodes are embedded in other nodes,
> > this can cause sysfs naming collisions since full_name may be truncated.
> > 
> > Only use devicetree node name instead of the full devicetree path
> > as the mdio bus name.
> 
> Hi Sylvain
> 
> I'm not sure this is a good idea. It probably breaks my boards:
> 
> :/sys/class/mdio_bus# ls
> !mdio-mux!mdio@1!switch@0!mdio	0.1  0.4  400d0000.ethernet-1  fixed-0
> !mdio-mux!mdio@2!switch@0!mdio	0.2  0.8  400d1000.ethernet-2  mv88e6xxx-0
> 
> np->name is not unique, where as np->full_name is unique.
> 
> However, i can understand your problem with truncation. Maybe a better
> solution is to detect if truncation is going to happen. If so, use a
> concatenation of a hash of np->full_name, and the right hand part of
> np->full_name?
> 
Thanks for the feedback.

I am currently busy on something else; I should be able to look at this
next week or the following.

Regards,
Sylvain

> 	Andrew
