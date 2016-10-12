From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Wed, 12 Oct 2016 09:25:24 +0300
Message-ID: <1476253524.7776.8.camel@coelho.fi>
References: <20161010071943.4717-1-chris@rorvick.com>
         <1476108164.5210.11.camel@coelho.fi> <1476180668.17022.21.camel@tiscali.nl>
         <CAEUsAPYDPCP0NBaTmy4xqFJhAS4xFQYinoNTknxFT23ef0dk4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Chris Rorvick <chris@rorvick.com>, Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:48308 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754148AbcJLGzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 02:55:50 -0400
In-Reply-To: <CAEUsAPYDPCP0NBaTmy4xqFJhAS4xFQYinoNTknxFT23ef0dk4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,
On Tue, 2016-10-11 at 09:09 -0500, Chris Rorvick wrote:
> On Tue, Oct 11, 2016 at 5:11 AM, Paul Bolle <pebolle@tiscali.nl> wrote:
> > > This is not coming from the NIC itself, but from the platform's ACPI
> > > tables.  Can you tell us which platform you are using?
> 
> 
> Interesting.  I'm running a Dell XPS 13 9350.  I replaced the
> factory-provided Broadcom card with an AC 8260.  I can update the
> commit log to reflect this.

Okay, so this makes sense.  Those entries are probably formatted for
the Broadcom card, which the iwlwifi driver obviously doesn't
understand.  The best we can do, as I already said, is to ignore values
we don't understand.

I will also check what is the correct procedure in such cases, because
it is possible, in theory, that the format *matches* but applies only
to another device.


> > > If this is really bothering you, I guess I could apply this patch for
> > > now.  But as I said, this is not solving the actual problem.
> > 
> > 
> > Bikeshedding: I think IWL_INFO() is more appropriate, as info doesn't
> > imply one needs to act on this message, while warn does imply that
> > action is needed.
> 
> 
> Agreed.  I still think making this a warning is appropriate, but it
> seems pretty clear this is not an error.  This has nothing to do with
> how much it bothers me.  An error tells the user something needs to be
> fixed, but in this case the interface is working fine.  Making it a
> warning with an improved message will result in fewer people wasting
> their time.

Yes, so I'll try to stop wasting people's timing by trying to do the
correct thing without bothering the user at all. :)

Thanks for pointing this all out!
