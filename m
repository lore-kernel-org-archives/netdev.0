From: "Simon Barber" <simon@devicescape.com>
Subject: RE: about 802.11i IBSS support
Date: Wed, 25 Oct 2006 20:26:43 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B54F2@dhost002-46.dex002.intermedia.net>
References: <1161830844.9670.13.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:25524 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1422888AbWJZD03 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 23:26:29 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1161830844.9670.13.camel@devlinux-hong>
To: "Hong Liu" <hong.liu@intel.com>,
	"Jouni Malinen" <jkm@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's not possible to 'negotiate keys at the beginning' - since there is
no indication of a new station joining an IBSS. The first you ever know
about a station joining an IBSS is when you receive a frame from that
station.

Simon
 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Hong Liu
Sent: Wednesday, October 25, 2006 7:47 PM
To: Jouni Malinen
Cc: Jiri Benc; netdev
Subject: Re: about 802.11i IBSS support

On Wed, 2006-10-25 at 23:48, Jouni Malinen wrote:
> On Wed, Oct 25, 2006 at 04:54:41PM +0800, Hong Liu wrote:
> 
> > I am reading the 802.11i IBSS spec and trying to find if it is OK to

> > add patches to d80211 to support this feature.
> 
> Large parts of this will be outside d80211, but yes, I think d80211 
> should be made ready to support this (mainly in the multiple group 
> keys area).
> 
> > When a STA (say S1) joins in an IBSS network with N STAs, it must 
> > negotiate keys with all N STAs.
> 
> I don't think it is required to negotiate keys with all STAs of the 
> network unless it actually needs to communicate with them, i.e., there

> may be cases where it is not needed to send or receive data from some 
> of the nodes.

This may add complexity to the implementation.

If the STA wants to send broadcast data, it must distribute its group
key to all other STAs, and then it can send out the packet.

For RX, if it receives data from other STA it needs to find out whether
it has finished key negotiation with that STA. And it can not decrypt
the data until key negotiation is finished.

If we negotiate keys at the beginning, things will be simple.
But the cost is we may negotiating keys with STAs we may not communicate
with.

Thanks,
Hong
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
