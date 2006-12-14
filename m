From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 1/6] d80211: add IEEE802.11e/WMM MLMEs, Status Code and
	Reason Code
Date: Thu, 14 Dec 2006 13:24:21 +0800
Message-ID: <1166073861.2929.67.camel@debian.sh.intel.com>
References: <20061214040204.GA10643@mail.intel.com>
	 <200612132338.24077.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35551 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbWLNF0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 00:26:46 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612132338.24077.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 23:38 -0500, Michael Wu wrote:
> On Wednesday 13 December 2006 23:02, Zhu Yi wrote:
> > Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> >
> You should probably have more in the description..
> 
> > ---
> >
> >  include/net/d80211_mgmt.h |  148
> > +++++++++++++++++++++++++++++++++++++++++++++ 1 files changed, 148
> > insertions(+), 0 deletions(-)
> >
> d80211_mgmt.h was recently merged into include/linux/ieee80211.h.
> 
> > d83f6236e756f5f0bb1484d991884444f06704de
> > diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
> > index 87141d4..450c0a2 100644
> > --- a/include/net/d80211_mgmt.h
> > +++ b/include/net/d80211_mgmt.h
> > @@ -14,6 +14,39 @@
> >
> >  #include <linux/types.h>
> >
> > +struct ieee802_11_ts_info {
> > +	__le16 traffic_type:1;
> > +	__le16 tsid:4;
> > +	__le16 direction:2;
> > +	__le16 access_policy:2;
> > +	__le16 aggregation:1;
> > +	__le16 apsd:1;
> > +	__le16 up:3;
> > +	__le16 ack_policy:2;
> > +	u8 schedule:1;
> > +	u8 reserved:7;
> > +} __attribute__ ((packed));
> > +
> Mind eliminating the bitfields?

Yeah, I thought of it. But if it is defined something like below

struct ieee802_11_ts_info {
	short field;
	byte another_field;
} ts_info;

Then,

up = (ts_info.field1 & 0x3800) >> 11;
schedule = (ts_info.another_field & 0x01);

So if I want to use "schedule", I need to know more details (i.e. which
field it belongs to). Are these efficient?

Thanks,
-yi
