From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
 resetting -> dead NIC
Date: Tue, 17 Mar 2009 16:30:34 -0700
Message-ID: <1237332634.12207.11.camel@HP1>
References: <bug-12877-10286@http.bugzilla.kernel.org/>
 <20090315143214.90c71fb7.akpm@linux-foundation.org>
 <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Bernhard Schmidt" <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3798 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbZCQXgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 19:36:23 -0400
In-Reply-To: <49C01F7F.9030306@birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2009-03-17 at 15:09 -0700, Bernhard Schmidt wrote:
> Attached, both after the crash (tg3.crashed) and after I reloaded the 
> module (tg3.reloaded). Additional info, ifdown/ifup does not fix the 
> situation, both take pretty long
> 

Thanks for the information.  The memory enable bit in the PCI command
register was cleared during tx_timeout.  That's why all the registers
were reading 0xffffffff.  The tx_timeout code in tg3 would not be able
to reset the chip if that bit was cleared.  We need to find out why that
bit was cleared.  We should also enhance the tx timeout code so that it
can recover more completely even if the memory enable bit is cleared.

Thanks.


