From: Dan Williams <dcbw@redhat.com>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not
 working with wireless drivers
Date: Wed, 16 Aug 2017 21:11:47 -0500
Message-ID: <1502935907.30484.4.camel@redhat.com>
References: <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com>
         <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
         <1502918561.30484.1.camel@redhat.com>
         <20170816.143116.1172751167543812070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: james@nurealm.net, futur.andy@googlemail.com, kvalo@codeaurora.org,
        arend.vanspriel@broadcom.com, maheshb@google.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37642 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751461AbdHQCNa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 22:13:30 -0400
In-Reply-To: <20170816.143116.1172751167543812070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 14:31 -0700, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Wed, 16 Aug 2017 16:22:41 -0500
> 
> > My biggest suggestion is that perhaps bonding should grow
> hysteresis
> > for link speeds. Since WiFi can change speed every packet, you
> probably
> > don't want the bond characteristics changing every couple seconds
> just
> > in case your WiFi link is jumping around.  Ethernet won't bounce
> around
> > that much, so the hysteresis would have no effect there.  Or, if
> people
> > are concerned about response time to speed changes on ethernet
> (where
> > you probably do want an instant switch-over) some new flag to
> indicate
> > that certain devices don't have stable speeds over time.
> 
> Or just report the average of the range the wireless link can hit,
> and
> be done with it.
> 
> I think you guys are overcomplicating things.

That range can be from 1 to > 800Mb/s.  No, it won't usually be all
over that range, but it won't be uncommon to fluctuate by hundreds of
Mb/s.  I'm not sure a simple average is really the answer here.  Even
doing that would require new knobs to ethtool, since the rate depends
heavily on card capabilities and also what AP you're connected to *at
that moment*.  If you roam to another AP, then the max speed can
certainly change.

You'll probably say "aim for the 75% case" or something like that,
which is fine, but then you're depending on your 75% case to be (a)
single AP, (b) never move (eg, only bond wifi + ethernet), (c) little
radio interference.  I'm not sure I'd buy that.  If I've put words in
your mouth, forgive me.

Dan
