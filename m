From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Mon, 28 Oct 2013 08:33:20 -0700
Message-ID: <20131028083320.63d3259f@nehalam.linuxnetplumber.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	<201310281449.58170@pali>
	<1382968522.17956.11.camel@jlt4.sipsolutions.net>
	<201310281500.24159@pali>
	<1382971562.1542.6.camel@dcbw.foobar.com>
	<1382972215.17956.30.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Pali =?ISO-8859-1?B?Um9o4XI=?= <pali.rohar@gmail.com>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382972215.17956.30.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Oct 2013 15:56:55 +0100
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Mon, 2013-10-28 at 09:46 -0500, Dan Williams wrote:
> 
> > If the device doesn't actually *have* a permanent MAC address, then it
> > shouldn't be returning one via ethtool, and should return an error for
> > ETHTOOL_GPERMADDR.
> 
> There's currently no provision for that, but I agree it would be better
> to do so.
> 
> johannes
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The current netdevice API handle the case of a device without a permanent
MAC address, slightly differently.

If device does not have a permanent address,
then:
  1. dev->addr_assign_type should not be NET_ADDR_PERM
  2. when device is registered dev->perm_addr will not be set
     and retain all zeros value
  4. when ethtool gets address it will return all zeros which
     is not a valid address.

This case doesn't seem to be handled threo mac80211 API's
