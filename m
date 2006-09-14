From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] genetlink custom attribute type
Date: Thu, 14 Sep 2006 10:14:09 +0200
Message-ID: <20060914081409.GB18349@postel.suug.ch>
References: <1158219852.2936.12.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:29393 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751459AbWININu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 04:13:50 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1158219852.2936.12.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-09-14 09:44
> This patch adds an NLA_CUSTOM_CHECK type for netlink attributes
> in order to be able to centrally define new attribute structures
> instead of having to check these special types in each function
> that uses such an attribute.
> 
> nl80211 will benefit from this because it needs an information
> element attribute with a fixed type|length|value structure defined
> in IEEE 802.11 which ought to be checked when passing an IE from
> userspace.

Looks good, we have to watch the size of struct nla_policy though.
This bumps the size from 4 bytes to 16 bytes on 64bit architectures
which might become a problem since we always use ATTR_MAX sized
arrays.
