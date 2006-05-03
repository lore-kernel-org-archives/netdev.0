From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client MLME
Date: Wed, 3 May 2006 09:44:58 -0700
Message-ID: <20060503164458.GB10524@instant802.com>
References: <20060502211817.GA30842@instant802.com> <20060503182815.1a9ebb5e@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-38.dex002.intermedia.net ([64.78.21.123]:32392 "EHLO
	dhost002-38.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030241AbWECQpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 12:45:03 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060503182815.1a9ebb5e@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2006 at 06:28:15PM +0200, Jiri Benc wrote:

> It is too early for this. We need to implement some better communication
> interface between kernel and hostapd (or what will implement userspace
> MLME) first. The current solution, where there is some special
> net_device interface (wmaster0ap) abused to dump informations to
> userspace, is ugly and confusing for users.

Why do you think that this would be too early now? I agree that the
interface between kernel and user space MLME can be improved, but I see
no point in making client MLME implementation wait for that to happen.
Personally, I don't think that the wmaster#ap interface is really that
ugly, but I have nothing against this being improved if someone has time
for doing it. I just don't see it as the highest priority.

> There is no userspace MLME implementation yet. And if one is going to be
> written, I'm really convinced it should be written in a clean way. I
> think Simon said he would examine a possibility to convert this stuff to
> netlink - is there some progress there?

But there is.. I committed changes to the wpa_supplicant devel branch
for this yesterday. It seems to work fine with net/d80211 and bcm43xx
with this small patch to d80211 to allow the functionality to be moved
into user space.

I have not yet heard of anyone working with details of converting the
management frame communication to use netlink.

> Also, I'm not sure how fullmac cards could be (potentially) supported
> with this approach.

In the same way as with the kernel space MLME implementation.. This
does not really change regardless of where the MLME code is implemented.
Some time ago, I sent a preliminary patch showing what kind of changes
are needed and this was mainly avoiding calls to some ieee80211_sta.c
functions.

-- 
Jouni Malinen                                            PGP id EFC895FA
