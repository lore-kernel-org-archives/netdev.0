From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Fri, 11 Mar 2016 15:26:42 -0800
Message-ID: <56E35432.2010300@gmail.com>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33480 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbcCKX2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:28:16 -0500
Received: by mail-pf0-f170.google.com with SMTP id 124so94040800pfg.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:28:15 -0800 (PST)
In-Reply-To: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 15:08, Andrew Lunn wrote:
> Currently, supporting a fixed-phy in a MAC driver is a bit messy. It
> needs to be explicit supported, since a fixed phy is somewhat
> different from a normal phy.
> 
> These two patches solve this by making fixed-phys appear as normal
> PHYs within device tree, allowing them to be referenced by a phandle.
> Any MAC driver that supports phy-handle can then automatically support
> a fixed-phy without any code change.

Humm, if that's the problem we want to solve, we could introduce a
helper function which tries to locate the phy using a 'phy-handle'
property, and if it fails falls back to looking for a fixed-link
property and use that if desired. That behavior could either be
automatic, or controlled via boolean flag for instance which indicates
whether fallback is appropriate?

I am not sure the virtual MDIO bus is looking much better in that
regard, it does provide a good model for how the fixed PHYs are
implemented: as a virtual MDIO bus, but that seems quite a bit of a
stretch here...
-- 
Florian
