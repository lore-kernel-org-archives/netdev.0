From: jason.morgan@aveillant.com
Subject: RE: tx checksum offload in rtl8168evl disabled in driver
Date: Fri, 4 Oct 2013 10:37:12 +0100
Message-ID: <OF682E8083.1CE559C7-ON80257BFA.00349A7B-80257BFA.0034D52E@aveillant.com>
References: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com> <20131003230120.GA25047@electric-eye.fr.zoreil.com> <74E4D3B5C4DF44108C5A942E88F3B18E@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-240.asp.reflexion.net ([69.84.129.240]:46390 "EHLO
	asp.reflexion.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751149Ab3JDJgj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 05:36:39 -0400
In-Reply-To: <74E4D3B5C4DF44108C5A942E88F3B18E@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems TX Early is a miss-feature, surely this is what needs to be 
turned off by default and not the tx-offload.
Yes it reduces latency, but at the expense of a lower overall throughput.



From:   hayeswang <hayeswang@realtek.com>
To:     'Francois Romieu' <romieu@fr.zoreil.com>, 
<jason.morgan@aveillant.com>, 
Cc:     <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>
Date:   04/10/2013 04:10
Subject:        RE: tx checksum offload in rtl8168evl disabled in driver



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
> thread. I've 
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
For jumbo frame, the hw starts to send a packet before getting the whole 
data.
However, the checksum has to be calculated after the whole data are 
fetched.
Therefore, the jumbo frame and the tx checksum couldn't be enable at the 
same
time, otherwise a packet with incorrect checksum would be sent.

Best Regards,
Hayes
