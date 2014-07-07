From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Mon, 7 Jul 2014 20:50:05 +0200
Message-ID: <20140707185005.GA1105@thinkoso.home>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
 <1404751280.22000.11.camel@dcbw.local>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42153 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaGGStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 14:49:47 -0400
Content-Disposition: inline
In-Reply-To: <1404751280.22000.11.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

On Mon, Jul 07, 2014 at 11:41:20AM -0500, Dan Williams wrote:
> On Mon, 2014-07-07 at 11:06 +0200, Olivier Sobrie wrote:
> > When the module sends bursts of data, sometimes a deadlock happens in
> > the hso driver when the tty buffer doesn't get the chance to be flushed
> > quickly enough.
> > 
> > To avoid this, first, we remove the endless while loop in
> > put_rx_bufdata() which is the root cause of the deadlock.
> > Secondly, when there is no room anymore in the tty buffer, we set up a
> > timer of 100 msecs to give a chance to the upper layer to flush the tty
> > buffer and make room for new data.
> 
> I assume this problem happens when using PPP for data transfer, instead
> of using the network port that the modules expose?  Or maybe the NMEA
> port?  I can't imagine that AT commands would make this happen...

Yes it happens when using ppp for data transfer.
The transfer of a large file sometimes triggers the problem.

-- 
Olivier
