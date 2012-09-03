From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 5/7] stmmac: add sysFs support
Date: Mon, 03 Sep 2012 15:36:05 +0200
Message-ID: <5044B245.5050703@st.com>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>  <1346658422-1925-6-git-send-email-peppe.cavallaro@st.com> <1346676267.7787.82.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:38639 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751596Ab2ICNgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 09:36:12 -0400
In-Reply-To: <1346676267.7787.82.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

On 9/3/2012 2:44 PM, Ben Hutchings wrote:
> On Mon, 2012-09-03 at 09:47 +0200, Giuseppe CAVALLARO wrote:
>> This patch adds the sysFs support.
>> Some internal driver parameters can be tuned by using some
>> entries exposed via sysFS. There parameter currently are,
>> for example, for internal timers used to mitigate the rx/tx
>> interrupts or for EEE.
> [...]
> 
> Why are you not exposing these through the standard ethtool operations?
> 
> Ben.

yes I want to expose them via ethtool and I'll do this as soon as I have
clear with ethtool parameters have to be used (
http://marc.info/?l=linux-netdev&m=134561966226677&w=2 ).

For the reception side, I have the RI Watchdog Timer count field and I
do not know what is the appropriate ethtool parameter to use.
>From the Synopsys databook, the RI Watchdog Timer count indicates the
number of system clock cycles. When the it runs out, the receive
interrupt bit is set and the timer is stopped.
No idea if it can be actually covered, for example, with
rx_coalesce_usecs_irq.

For the transmission I have a SW timer that periodically calls the tx
function (stmmac_tx) and a threshold to also set the "Interrupt on
completion" bit in the TDES when a frame is transmitted.
I wonder (but not sure) if in this case I could be: tx_coalesce_usec and
tx_mac_coalesced_frames.
>From the kernel documentation IIUC these seem to have other meaning.

No problem, to extend ethtool to cover these kind of parameters if
necessary.

Welcome advice,
Peppe
