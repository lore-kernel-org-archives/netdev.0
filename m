From: "Nikita N." <nikitan@operamail.com>
Subject: Re: brcmsmac: TX power blocked in BCM4313
Date: Mon, 16 Feb 2015 10:53:07 -0800
Message-ID: <1424112787.3303548.228201005.68F1D224@webmail.messagingengine.com>
References: <1424007136.2042747.227726249.45B6A0E2@webmail.messagingengine.com>
 <1424094835.3188168.228077393.0E2006F5@webmail.messagingengine.com>
 <54E2107F.4000709@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hauke@hauke-m.de, brcm80211-dev-list@broadcom.com,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Pat Erley <pat-lkml@erley.org>, brudley@broadcom.com,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54E2107F.4000709@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arend,
first of all, thank you for your answer.

I'm very sorry to hear that negative feedback.
So, AFAIU, there is no support in brcmsmac for regdom and power
settings.

I don't know how much Broadcom Corp. is complaint with IEEE Standard
802.11-2007 (page 531), along that decision.
Missing also the support for a complete functioning of tools such as
iwconfig and iw, doesn't put Broadcom Corp. very much Linux supporting.
When in fact in the Windows driver, the TX power control is explicitly
enabled and fully operational.

Now, I googled around, and found the following page:
http://www.broadcom.com/support/802.11/linux_sta.php
the README states explicitly:
"iwconfig eth1 txpower & iwlist eth1 txpower set and get the drivers
user-requested transmit power level. This can go up to 32 dbm and allows
the user to lower the tx power to levels below the regulatory limit.
Internally, the actual tx power is always kept within regulatory limits
no matter what the user request is set to."

Unfortunately, I don't know if also that STA driver works or not,
because I was not even able to successfully compile&install it over
latest Ubuntu shipped backports, even if applied all bug patches.
Whose patches, BTW, are coming open-source also from contributors out of
Broadcom Corp, driven simply by the wish to help the community, for
free.

So I would like to ask 3 questions:
1) Why the same STA redgom and power support (shipped with that STA
driver) was not applied also over the latest Linux backports?
2) What exact Ubuntu core version and backports version, have been
adapted by responsibility of Broadcom QA Testing team, to verify the
correctness of specifications advertized officially on that Broadcom
Corp. web page README?

Finally I would like to take the opportunity to ask you Arend, about a
issue I raised a year ago, here a remind FYI:
http://permalink.gmane.org/gmane.linux.kernel.wireless.general/117985

After more than *ONE* year, still the brcmsmac driver can not detect 11n
modulated frames in monitor mode.
Question:
3) Can (at least) that STA driver detect 11n modulated frames in monitor
mode?

I hope you or someone here will be able to answer those questions,
because I'm not going to replicate them elsewhere.
Since I got really frustrated by all those unsatisfactory products and
results from Broadcom Corp., the unsatisfactory support towards Linux
community, and the unsatisfactory Customers care.

Thanks for your attention. 
-- 
  Nikita N.
  nikitan@operamail.com


On Mon, Feb 16, 2015, at 07:45 AM, Arend van Spriel wrote:
> On 02/16/15 14:53, Nikita N. wrote:
> > Hi Dear brcmsmac Devs,
> > following up my previous email, since I didn't receive any feedback, I
> > took the trouble to test my understandings myself.
> > First of all, I want to report the following fact: the TX power is
> > blocked/fixed to 19dbm, no matter what local regdom or power setting.
> 
> Hi Nikita,
> 
> We saw your previous email just this morning. Basically, tx power 
> control is explicitly disabled in brcmsmac. I think it was one of the 
> internal requirements to get approval for this open-source effort.
> 
> > If that is an issue or bug or else I leave the decision to you.
> > Another fact is that, the Windows driver for that same interface, is
> > capable to push the transceiver at least 10 RSSI points higher than
> > linux backports brcmsmac driver, which means it is *DO* possible to
> > change the TX power.
> > In my personal case I want to lower it, but even that is not possible:
> > no setting is working, neither changing the regdom (iw reg set) nor the
> > power (iwconfig wlan0 txpower, iw dev wlan0 set txpower fixed, iw phy
> > wlan0 set txpower fixed).
> >
> > Now, as for my tests, I just tried to hard-code few values into the
> > brcmsmac driver module, only to see if anything changes.
> > In details I zeroed the values of all tx_power_offsets in the table
> > populated in wlc_lcnphy_txpower_recalc_target (phy_lcn.c), and called
> > wlc_lcnphy_set_target_tx_pwr with a value of 40 (minor that 52, which is
> > the minimum I found debugging that function).
> > Again, nothing changed (even if further calls to
> > wlc_lcnphy_set_target_tx_pwr =40)
> >
> > It is my wish to create a patch for that "issue", which I want first to
> > test here locally to me, and if working&interesting, I can propose it
> > for merging in next release.
> > But, AMOF, now I'm just stuck.
> >
> > In case anybody feels like giving away any hint/feedback, I would have
> > few questions:
> > 1) is it "brcmsmac" linux backports driver still supported or
> > deprecated?
> > 2) if deprecated, what is the supported driver for BCM4313?
> > 3) About my tests, was it correct zeroing all tx_power_offsets in the
> > table and call wlc_lcnphy_set_target_tx_pwr=40, to get a TX power less
> > that 19dbm?
> > 4) if it was not correct, or partially correct, what am I missing or
> > doing wrong, in order to push the TX transceiver power less than 19dbm?
> 
> Sorry to say but I can not help you. I can not encourage (nor 
> discourage) changing the phy code.
> 
> Regards,
> Arend

-- 
http://www.fastmail.com - Send your email first class
