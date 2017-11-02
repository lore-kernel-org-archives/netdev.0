From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Thu, 2 Nov 2017 01:14:22 +0100
Message-ID: <20171102001422.GA4772@lunn.ch>
References: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
 <20171101121611.GD12680@lunn.ch>
 <b789b023-2e7b-1f5b-59a6-9676db74e850@maciej.szmigiero.name>
 <20171101123102.GF12680@lunn.ch>
 <fb6da2f4-38a7-a116-1910-51795ebb53da@maciej.szmigiero.name>
 <698c7dea-7b32-e63c-11ac-feac163a65a1@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <698c7dea-7b32-e63c-11ac-feac163a65a1@maciej.szmigiero.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2017 at 12:49:31AM +0100, Maciej S. Szmigiero wrote:
> Hi Andrew,
> 
> On 01.11.2017 13:33, Maciej S. Szmigiero wrote:
> > On 01.11.2017 13:31, Andrew Lunn wrote:
> >>> Yes, I did it the same way as the existing code did for phy->phy_led_triggers
> >>> for reasons of both consistency and also to be on the safe side because
> >>> maybe there is some non-obvious reason why it has to be freed
> >>> explicitly (?).
> >>  
> >> Hi Maciej
> >>
> >> Occasionally, there is a need to call devm_kfree(). But i don't see
> >> anything here why it is needed. So i would drop your devm_kfree(), and
> >> if you feel like it, add an additional patch removing the existing
> >> one.
> > 
> > OK, will do as you suggest.
> > 
> 
> Upon closer inspection of the code it turned out that these devm_kfree()
> calls actually had some purpose - the PHY core ignores the return value
> of phy_led_triggers_register() and will successfully attach a PHY even
> if this function returns an error.
> 
> In that case these LED trigger structures would unnecessary take some
> memory, that's why (probably) the PHY LED code frees them on error
> path.

O.K. Thanks for looking into this.

     Andrew
