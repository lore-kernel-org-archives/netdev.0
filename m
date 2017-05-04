From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Thu, 4 May 2017 09:31:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE535E@AcuExch.aculab.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503221944.1dd0d576@xeon-e3> <20170504061559.GA2162@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "joe@perches.com" <joe@perches.com>,
        "kubakici@wp.pl" <kubakici@wp.pl>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Gavin Shan' <gwshan@linux.vnet.ibm.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:59517 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751407AbdEDJb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 05:31:29 -0400
In-Reply-To: <20170504061559.GA2162@gwshan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan
> Sent: 04 May 2017 07:16
> On Wed, May 03, 2017 at 10:19:44PM -0700, Stephen Hemminger wrote:
> >On Wed,  3 May 2017 14:44:35 +1000
> >Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
...
> >> +{
> >> +	struct ethtool_ncsi_channels *enc;
> >> +	short nr_channels;
> >Should be __u16 or unsigned not short.
> >
> 
> Nope, It's for signed number. User expects to get number of available
> channels when negative number is passed in. When it's positive, it's
> going to get the channels' information.

Why 16 bits?
You are just making life hard for the compiler and possibly generating
random padding.

I guess the user is expected to pass -1 first to get the number of
channels, then allocate an appropriate sized array and call again
specifying the number of channels?

What happens if the number of channels changes between the two requests?

I'd also suggest passing the size of each entry (in at least one direction).
That way additional channel information can be added.

	David
