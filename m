From: Stefan Rompf <stefan@loplof.de>
Subject: Re: State of the Union: Wireless
Date: Fri, 6 Jan 2006 13:48:05 +0100
Message-ID: <200601061348.05803.stefan@loplof.de>
References: <20060106042218.GA18974@havoc.gtf.org> <1136547084.4037.41.camel@localhost> <20060106114620.GA23707@isilmar.linta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932224AbWAFMqH@vger.kernel.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
In-Reply-To: <20060106114620.GA23707@isilmar.linta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag 06 Januar 2006 12:46 schrieb Dominik Brodowski:

> From someone who has no idea at all (yet) about 802.11: why character
> device, and not sysfs or configfs files? Like

sysfs shares the main problem with wireless extensions: It configures one 
value per file / per ioctl. Setting up a wireless card to associate or form 
an IBSS network consists of multiple parameters, many requiring the card to 
disasscociate.

With hardware like prism2 usb that gets "don't touch me now mode" for a while 
after a join command is issued, current API requires a driver to delay 
starting an association in order to wait if other config requests are issued 
- an ugly hack.

I vote for netlink. It's a defined and tested interface and has all features 
needed to set multiple values in one transaction.

Stefan
