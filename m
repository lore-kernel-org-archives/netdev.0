From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Thu, 24 Mar 2016 19:50:05 +0100
Message-ID: <20160324185005.GD15624@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <20160323185006.GL5250@lunn.ch>
 <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
 <20160323211010.GF19953@lunn.ch>
 <CAC3a_SBjvQFT5XP2bH3TO_4wHnjZ3a3+XvfBy8StxQieEsavQQ@mail.gmail.com>
 <20160324132935.GA15624@lunn.ch>
 <CAC3a_SDK8aoz1KKXa9FYBj8a1q8EPMLtVe94mGemeh7Wf=BL4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56385 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbcCXSuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 14:50:08 -0400
Content-Disposition: inline
In-Reply-To: <CAC3a_SDK8aoz1KKXa9FYBj8a1q8EPMLtVe94mGemeh7Wf=BL4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew,
> 
> I still have some questions. Will the phylib call this
> led_trigger_register_to_led() function for registering the trigger
> instead of calling led_trigger_register()?

Each phy driver needs to call led_classdev_register() for each LED it
has. It then also calls led_trigger_register_to_led() with the
triggers that each LED supports.

> > function which registers a trigger to a specific LED, on its own
> > trigger list. led_trigger_store() and led_trigger_show() would use
> > both lists.
> 
> In case of led_trigger_store(), how to stop the non-PHY LEDs to
> register themselves from eth-phy-activity trigger.

They won't have the option. led_trigger_register_to_led() only
registers the trigger to one specific LED, i.e. adds it to the trigger
list in its led_classdev structure, not the global list of triggers.

     Andrew
