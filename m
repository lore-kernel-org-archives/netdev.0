From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/6] net: phy: Threaded interrupts allow some
 simplification
Date: Wed, 28 Sep 2016 14:28:35 +0200
Message-ID: <20160928122835.GB22809@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-4-git-send-email-andrew@lunn.ch>
 <7997d337-cd0f-ab39-1f53-df996063932b@cogentembedded.com>
 <af8f7c76-f2fe-95ac-4151-0189baf84a53@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35103 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932179AbcI1M2h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 08:28:37 -0400
Content-Disposition: inline
In-Reply-To: <af8f7c76-f2fe-95ac-4151-0189baf84a53@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 03:13:46PM +0300, Sergei Shtylyov wrote:
> On 9/28/2016 2:46 PM, Sergei Shtylyov wrote:
> 
> >>The PHY interrupts are now handled in a threaded interrupt handler,
> >>which can sleep. The work queue is no longer needed, phy_change() can
> >>be called directly. Additionally, none of the callers of
> >>phy_mac_interrupt() did so in interrupt context, so fully remove the
> >
> >   I did intend to call it from interrupt context (from the ravb driver).
> >
> >>work queue, and document that phy_mac_interrupt() should not be called
> >>in interrupt context.
> >
> >   It was intentionally made callable from the interrupt context, I'd prefer
> >if you wouldn't change that.
> 
>    OTOH, it's still not very handy to call because of the 'new_link'
> parameter which I'm not sure I can provide...

Hi Sergei

If there is a need for it, i will leave the work queue and keep this
code unchanged.

   Andrew
