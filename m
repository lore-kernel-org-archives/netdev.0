From: Dan Williams <dcbw@redhat.com>
Subject: Re: 3945 driver using d80211
Date: Wed, 09 Aug 2006 15:22:31 -0400
Message-ID: <1155151351.5788.8.camel@localhost.localdomain>
References: <44D901C9.6090304@linux.intel.com>
	 <200608081440.48623.flamingice@sourmilk.net>
	 <44D99558.1000507@sipsolutions.net>
	 <200608090947.20291.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Mohamed Abbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53724 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751301AbWHITVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 15:21:32 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608090947.20291.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-09 at 09:47 -0700, Michael Wu wrote:
> On Wednesday 09 August 2006 00:57, Johannes Berg wrote:
> > Please not, for now. We need someone pushing for fullmac features in
> > d80211, we need those anyway for embedded systems that can't afford
> > running all of it on the main CPU. While obviously Intel would benefit
> > from doing this since a lot more d80211 features would come available,
> > the greater good would be having a main-stream card that someone cares
> > about and helps making d80211 full-mac capable.
> >
> It's not that hard to generate probe, authentication, and association frames, 
> and it isn't done frequently enough to stress any embedded system that can 
> run linux. Doing this would let 3945 take advantage of all the d80211 
> features, so why not?
> 
> What level of fullmac support are we talking about? True fullmac cards (as I 
> define them) do not need to use d80211. WE19 is all they need, to add 
> WPA/WPA2 support. The IPW cards have a particularly unique split between 
> firmware and host 802.11 duties which I haven't seen in any other cards. They 
> aren't quite fullmac enough to interface with WE directly, yet they only need 
> probe response handling to complete the picture. What other half-fullmac, 
> half-softmac card besides the other IPW cards splits card/host 802.11 duties 
> along those lines? What other splits between card and host are out there? I 
> would be very reluctant to make changes to the 802.11 stack to support 
> "fullmac" without evidence that other drivers need the change.

The atmel driver is somewhat of a hybrid.  For fullmac cards like airo,
you just set the connection info up, let the card go, and you get back a
link event.  But the atmel driver controls authentication and
association stuff; that's not done in firmware.  Look at:

send_authentication_request()
send_association_request()
atmel_transmit_management_frame()
atmel_management_frame()
authenticate()
associate()

The driver has an auth/assoc state machine, receives management frames,
and sends out the next appropriate management frame based on the current
state.  I think this is the reverse of ipw2100, where the firmware
handles assoc/auth but not much else, but it's still less fullmac than
airo, and more fullmac than softmac.

Dan


