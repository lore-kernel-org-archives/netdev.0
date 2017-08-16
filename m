From: Dan Williams <dcbw@redhat.com>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not
 working with wireless drivers
Date: Wed, 16 Aug 2017 16:22:41 -0500
Message-ID: <1502918561.30484.1.camel@redhat.com>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
         <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
         <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg@mail.gmail.com>
         <87tw1edz5j.fsf@kamboji.qca.qualcomm.com>
         <87tw1dck6o.fsf@kamboji.qca.qualcomm.com>
         <deb37db2-a55b-4010-475a-e756e67d3bc9@nurealm.net>
         <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com>
         <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Ben Greear <greearb@candelatech.com>
To: james@nurealm.net, Andreas Born <futur.andy@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33986 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752219AbdHPVYY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 17:24:24 -0400
In-Reply-To: <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 14:44 -0600, James Feeney wrote:
> On 08/13/2017 11:42 AM, Andreas Born wrote:
> > On a side note I would recommend some of my own reading to you
> > about
> > patch submission in general [1] and on netdev specifically [2].
> 
> Mmm - [2] and [3], I suspect.  Thanks Andreas.  I'll be studying
> those.  Yeah,
> I'm still learning what is needed and what works.  Sometimes, just a
> note to the
> author is more than enough to resolve a problem.  Sometimes,
> discussion is
> needed.  And other times... well, certain people are infamous... but
> no problem
> here, thankfully.
> 
> > And, just wondering, who's going to eventually close that
> > bugreport?
> > https://bugzilla.kernel.org/show_bug.cgi?id=196547
> 
> I can close it when the patches actually land in the kernel.  I'm
> glad to see
> that there was an "Ack" from Mahesh.
> 
> On the topic of wireless support for kernel ethtool reporting, I'm
> wondering, is
> there is any consensus about that?
> 
> And, for instance, is there any *other* way for the bonding module to
> make
> "better link" decisions for wireless links?  As "wireless" becomes
> more capable,
> possibly more diverse, and probably more essential for computing,
> this is likely
> to become a bigger issue.
> 
> Ben Greear mentioned that he had added some support to the ath10k
> driver.  Dan
> Williams mentioned the possibility of updating the mac80211 stack for
> support.
> And Arend van Spriel suggested that the issue might best be left for
> the next
> Netconf.
> 
> Immediate problem solved, but maybe a larger issue still needs to be
> addressed?

Again, it's technically possible to add the link settings support to
wireless drivers.  But the issue is around what bonding would do with
that information in its various modes.

My biggest suggestion is that perhaps bonding should grow hysteresis
for link speeds. Since WiFi can change speed every packet, you probably
don't want the bond characteristics changing every couple seconds just
in case your WiFi link is jumping around.  Ethernet won't bounce around
that much, so the hysteresis would have no effect there.  Or, if people
are concerned about response time to speed changes on ethernet (where
you probably do want an instant switch-over) some new flag to indicate
that certain devices don't have stable speeds over time.

Dan
