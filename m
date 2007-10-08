From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/3] [NET_BATCH] Introduce batching interface
Date: Mon, 08 Oct 2007 09:49:14 -0400
Message-ID: <1191851354.4352.57.camel@localhost>
References: <OF821E811C.0B4972CE-ON6525736E.0035FA06-6525736E.0036D812@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:14825 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbXJHNtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 09:49:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1324751wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 06:49:23 -0700 (PDT)
In-Reply-To: <OF821E811C.0B4972CE-ON6525736E.0035FA06-6525736E.0036D812@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 15:29 +0530, Krishna Kumar2 wrote:
> Hi Jamal,
> 
> If you don't mind, I am trying to run your approach vs mine to get some
> results for comparison.

Please provide an analysis when you get the results. IOW, explain why
one vs the other get different results.

> For starters, I am having issues with iperf when using your infrastructure
> code with
> my IPoIB driver - about 100MB is sent and then everything stops for some
> reason.

I havent tested with iperf in a while.
Can you post the netstat on both sides when the driver stops?
It does sound like a driver issue to me.

> The changes in the IPoIB driver that I made to support batching is to set
> BTX, set
> xmit_win, and dynamically reduce xmit_win on every xmit 
> and increase xmit_win on every xmit completion. 

>From driver howto:
---
This variable should be set during xmit path shutdown(netif_stop),
wakeup(netif_wake) and ->hard_end_xmit(). In the case of the first
one the value is set to 1 and in the other two it is set to whatever
the driver deems to be available space on the ring.
----

> Is there anything else that is required from the
> driver?

Your driver needs to also support wake thresholding.
I will post the driver howto later today.

cheers,
jamal

