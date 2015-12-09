From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH (net-next.git) 13/18] stmmac: perf, remove modulo in
 stmmac_rx()
Date: Wed, 9 Dec 2015 17:21:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE9BB2@AcuExch.aculab.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
 <1449650274-14896-14-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: 'Giuseppe Cavallaro' <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:61441 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbbLIRXa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 12:23:30 -0500
In-Reply-To: <1449650274-14896-14-git-send-email-peppe.cavallaro@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro
> Sent: 09 December 2015 08:38
> The indexes into the ring buffer are always incremented, and
> the entry is accessed via doing a modulo to find the "real" index.
> Modulo is an expensive operation.
> 
> This patch replaces the modulo with a simple if clamp.
> It helps improve stmmac RX path as it's being called inside RX loop.

Is dma_rx_size always a power of 2 ?
If so you can replace the % by & and remove the conditionals.

If you have changed the read and write values to indexes
then you need to be certain that the 'ring full' and 'ring empty'
cases are correctly distinguished.

	David
