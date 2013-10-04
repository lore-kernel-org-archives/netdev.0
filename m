From: hayeswang <hayeswang@realtek.com>
Subject: RE: tx checksum offload in rtl8168evl disabled in driver
Date: Fri, 4 Oct 2013 11:10:48 +0800
Message-ID: <74E4D3B5C4DF44108C5A942E88F3B18E@realtek.com.tw>
References: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com> <20131003230120.GA25047@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	<jason.morgan@aveillant.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:35717 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008Ab3JDDK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 23:10:59 -0400
In-Reply-To: <20131003230120.GA25047@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > I'm using 2k to 4k frames with a rtl8168evl.
> > I've found this message
> > http://www.spinics.net/lists/netdev/msg216530.html
> [...]
> > However the message thread, above indicates that this is 
> not a problem and 
> > can be changed to make tx-checksum offload possible.
> > 
> > However we are using a newer chip to the on in the message 
> thread.  I've 
> > tried to find other, more recent citations without success.
> > 
> > So, why is it still turned off ?
> 
> It has been disabled since 
> d58d46b5d85139d18eb939aa7279c160bab70484 ("r8169:
> jumbo fixes"). Patch was submitted as a RFC on 2011/07/17 and 
> Hayes was
> explicitely requested to comment on the jumbo part if 
> necessary. Patch was
> submitted for inclusion on 2011/09/22.
> 
> Tx checksumming and jumbo are mutually exclusive in Realtek's 
> driver as well.
> 
> It seems no recent gigabit chipset reliably supports it.
> 
> > What will be the effect of turning it on (changing false to 
> true, in the 
> > driver line) for our chip ?

Since RTL8111E, the chips support a feature which we call "tx early".
For jumbo frame, the hw starts to send a packet before getting the whole data.
However, the checksum has to be calculated after the whole data are fetched.
Therefore, the jumbo frame and the tx checksum couldn't be enable at the same
time, otherwise a packet with incorrect checksum would be sent.
 
Best Regards,
Hayes
