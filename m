From: Jouni Malinen <j@w1.fi>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Mon, 17 Dec 2007 20:22:53 -0800
Message-ID: <20071218042253.GC5698@jm.kir.nu>
References: <1197483844.6558.158.camel@johannes.berg> <20071213204933.GD3083@tuxdriver.com> <1197634443.16079.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Tomas Winkler <tomasw@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:49633 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbXLREYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 23:24:07 -0500
Content-Disposition: inline
In-Reply-To: <1197634443.16079.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 01:14:03PM +0100, Johannes Berg wrote:

> I think in theory all eapol frames are sent to the PAE group address,
> but I have no idea which of the checks would be more efficient. It seems
> that the first could be optimised a lot because it's constant too...

They are not.. PAE group address is used for all EAPOL frames in
non-shared media LANs (e.g., wired Ethernet switch), but IEEE 802.11
uses the specific MAC address of the PAE since it is a shared media LAN
(i.e., the frames are between the unicast MAC address of the non-AP
STA/Supplicant and AP/Authenticator). If we end up having to drop the
PAE group addressed EAPOL frames in mac80211 anyway due to Linux
bridging code not doing this, we could combine these two validations and
just accept the unicast MAC address of the device itself as a valid
destination address for received EAPOL frames (and as the only valid
source address for transmitted ones).

-- 
Jouni Malinen                                            PGP id EFC895FA
