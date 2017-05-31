From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Wed, 31 May 2017 21:31:36 +0200
Message-ID: <20170531193136.GD11230@lunn.ch>
References: <59105EA3.9030203@aoifes.com>
 <20170508123852.GI27709@lunn.ch>
 <591AD990.901@aoifes.com>
 <20170516124759.GB27959@lunn.ch>
 <591AF9FD.1000304@aoifes.com>
 <20170516132116.GE5456@lunn.ch>
 <591B1FC2.1090402@aoifes.com>
 <20170516155843.GE32357@lunn.ch>
 <591B267D.1030800@aoifes.com>
 <5927FFAF.40301@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Rafa Corvillo <rafael.corvillo@aoifes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60145 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751067AbdEaTbj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 15:31:39 -0400
Content-Disposition: inline
In-Reply-To: <5927FFAF.40301@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 12:13:03PM +0200, Rafa Corvillo wrote:
> As modifying sky2 code I have not could get any solution, then I
> have modified some parameters on the ethernet interface and using a
> MTU = 1503 and disabling TSO (TCP Segmentation Offload) mechanism
> all communication errors disappear, both the rx errors due to too
> long packets and tx timeout errors.

Hi Rafa

That at least makes some sense. It would be interesting to sniff the
frames going from, the sky2 to the switch. I suspect you will find
that the first frame TSO sends for a big segment has the DSA header
and the following frames don't. You might want to look at how TSO is
setup on transmit, if you can tell it which parts of the header needs
to be placed on each segment, so that it includes the DSA header.

    Andrew
