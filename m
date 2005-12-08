From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Broadcom 43xx first results
Date: Thu, 8 Dec 2005 13:07:51 +0100
Message-ID: <20051208130751.6586c59d@griffin.suse.cz>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
	<20051205190038.04b7b7c1@griffin.suse.cz>
	<4394892D.2090100@gentoo.org>
	<20051205195543.5a2e2a8d@griffin.suse.cz>
	<4394902C.8060100@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	NetDev <netdev@vger.kernel.org>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751165AbVLHMHy@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4394902C.8060100@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Dec 2005 14:08:28 -0500, Jeff Garzik wrote:
> > Unfortunately, the only long-term solution is to rewrite completely the
> > current in-kernel ieee80211 code (I would not call it a "stack") or
> > replace it with something another. The current code was written for
> > Intel devices and it doesn't support anything else - so every developer
> 
> Patently false.

Maybe some explanation why current in-kernel ieee80211 code needs to be
rewritten will be useful.

1. To support WDS and devices capable to associate with multiple
networks, ieee80211_device needs to be separated to two (or even more,
see below) structures - one hardware dependent (channel and so) and one
link dependent (BSSID etc.).

2. To support AP mode, you need to keep a list of associated stations.
No such list exists now. Furthermore, that list (or that structure) can
be reused also by a client to store information about AP it is
associated to. And - possibly - for a list of APs it can associate to,
i. e. list of found networks. Currently, informations about AP are
hardwired into ieee80211_device structure.

3. Most of WE calls can be handled by ieee80211 itself. The rest should
be propagated to a driver in some easier way than requiring driver to
deal with the whole WE stuff itself. Also, exporting callbacks from
ieee80211 that driver has to set as particular WE handlers seems to be
unnecessary complicated.

4. Callbacks like handle_auth() that were added some time ago are not
needed (for explanation, see corresponding thread on netdev).

5. Some less important things, e. g. current very inefficient code which
deals with found networks.


-- 
Jiri Benc
SUSE Labs
