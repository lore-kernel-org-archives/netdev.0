From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 18:13:04 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5205CD3405@orsmsx418.amr.corp.intel.com>
References: <200808051047.15605.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Denys Fedoryshchenko" <denys@visp.net.lb>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8108 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762784AbYHFBNG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 21:13:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200808051047.15605.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> I did script, that looks something like this (to simulate SFQ by flow
> classifier):

<snip>

Just to clarify for e1000 message, this is a "false hang" as indicated
by .status = 1 and TDH==TDT and both are still moving, which means
adapter is still transmitting.

In this case it appears that the system took longer than two seconds to
allow the e1000 driver to clean up packets that it transmitted, in fact
it appears to be delayed by about a constant 700 jiffies or so.

> Error message appearing in dmesg:
> [149650.006939] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [149650.006943]   Tx Queue             <0>
> [149650.006944]   TDH                  <a3>
> [149650.006945]   TDT                  <a3>
> [149650.006947]   next_to_use          <a3>
> [149650.006948]   next_to_clean        <f8>
> [149650.006949] buffer_info[next_to_clean]
> [149650.006951]   time_stamp           <8e69a7c>
> [149650.006952]   next_to_watch        <f8>
> [149650.006953]   jiffies              <8e6a111>
> [149650.006954]   next_to_watch.status <1>
> [149655.964100] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [149655.964104]   Tx Queue             <0>
> [149655.964105]   TDH                  <6c>
> [149655.964107]   TDT                  <6c>
> [149655.964108]   next_to_use          <6c>
> [149655.964109]   next_to_clean        <c1>
> [149655.964111] buffer_info[next_to_clean]
> [149655.964112]   time_stamp           <8e6b198>
> [149655.964113]   next_to_watch        <c1>
> [149655.964115]   jiffies              <8e6b853>
> [149655.964116]   next_to_watch.status <1>

So I don't think this is any e1000 problem as it appears the rest of
your thread confirms, as it appears the system gets too busy trying to
traverse your tc filters and can't work on e1000 driver packet clean up.

Jesse
