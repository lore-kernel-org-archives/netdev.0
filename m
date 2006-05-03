From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client
 MLME
Date: Wed, 3 May 2006 20:10:59 +0200
Message-ID: <20060503201059.58477ea6@griffin.suse.cz>
References: <20060502211817.GA30842@instant802.com>
	<20060503182815.1a9ebb5e@griffin.suse.cz>
	<20060503164458.GB10524@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49848 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751331AbWECSLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 14:11:01 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060503164458.GB10524@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 May 2006 09:44:58 -0700, Jouni Malinen wrote:
> Why do you think that this would be too early now? I agree that the
> interface between kernel and user space MLME can be improved, but I see
> no point in making client MLME implementation wait for that to happen.
> Personally, I don't think that the wmaster#ap interface is really that
> ugly, but I have nothing against this being improved if someone has time
> for doing it. I just don't see it as the highest priority.

On the other hand, I'm afraid it will be hard to explain to users why
there are all these network interfaces (wmaster0, wmaster0ap) they
shouldn't touch at all. I'm trying to reduce those interfaces as much as
possible. We cannot avoid wmaster0, but we can avoid wmaster0ap. So I
see the new kernel->hostapd (wpa_supplicant) interface as a rather high
priority.

> But there is.. I committed changes to the wpa_supplicant devel branch
> for this yesterday. It seems to work fine with net/d80211 and bcm43xx
> with this small patch to d80211 to allow the functionality to be moved
> into user space.

Oh, sorry, didn't know that.

If you really feel this is a necessary feature (although I think we
should focus more on putting the stack to a form suitable for inclusion
in the kernel than on adding new features now), what about making the
wmaster0ap interface appear only when the device is switched to user
space MLME? Should I make a patch?

> I have not yet heard of anyone working with details of converting the
> management frame communication to use netlink.

With details - no, neither have I.

> > Also, I'm not sure how fullmac cards could be (potentially) supported
> > with this approach.
> 
> In the same way as with the kernel space MLME implementation.. This
> does not really change regardless of where the MLME code is implemented.

I had in mind cards with large parts of MLME implemented in their
firmware, when MLME is moved from the stack fully to userspace. Such
cards probably won't allow you to handle e. g. scanning by switching
channels and sending probe requests. I know, we're not going to support
them soon, but isn't this something that will disallow the suppport at
all?

Or do I understand it wrong?

> Some time ago, I sent a preliminary patch showing what kind of changes
> are needed and this was mainly avoiding calls to some ieee80211_sta.c
> functions.

Hm, I probably missed that patch (or maybe just can't remember). Could
you post a link or something?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
