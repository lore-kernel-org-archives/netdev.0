From: Hong Liu <hong.liu@intel.com>
Subject: Re: about 802.11i IBSS support
Date: Thu, 26 Oct 2006 10:47:24 +0800
Message-ID: <1161830844.9670.13.camel@devlinux-hong>
References: <1161766481.8668.38.camel@devlinux-hong>
	 <20061025154815.GA15348@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29367 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1161113AbWJZCyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 22:54:23 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061025154815.GA15348@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-25 at 23:48, Jouni Malinen wrote:
> On Wed, Oct 25, 2006 at 04:54:41PM +0800, Hong Liu wrote:
> 
> > I am reading the 802.11i IBSS spec and
> > trying to find if it is OK to add patches to d80211 to support this feature.
> 
> Large parts of this will be outside d80211, but yes, I think d80211
> should be made ready to support this (mainly in the multiple group keys
> area).
> 
> > When a STA (say S1) joins in an IBSS network with N STAs,
> > it must negotiate keys with all N STAs.
> 
> I don't think it is required to negotiate keys with all STAs of the
> network unless it actually needs to communicate with them, i.e., there
> may be cases where it is not needed to send or receive data from some of
> the nodes.

This may add complexity to the implementation.

If the STA wants to send broadcast data, it must distribute its group
key to all other STAs, and then it can send out the packet.

For RX, if it receives data from other STA it needs to find out whether it
has finished key negotiation with that STA. And it can not decrypt the data
until key negotiation is finished.

If we negotiate keys at the beginning, things will be simple.
But the cost is we may negotiating keys with STAs we may not communicate with.

Thanks,
Hong
