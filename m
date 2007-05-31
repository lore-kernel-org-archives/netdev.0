From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 08:23:24 -0700
Message-ID: <465EE86C.6080301@intel.com>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>	<20070531010814.GA30709@gondor.apana.org.au> <1180624569.23536.7.camel@athlon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Doug Chapman <doug.chapman@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12958 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbXEaPXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 11:23:31 -0400
In-Reply-To: <1180624569.23536.7.camel@athlon>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Doug Chapman wrote:
> On Thu, 2007-05-31 at 11:08 +1000, Herbert Xu wrote:
>> On Wed, May 30, 2007 at 05:22:30PM -0400, Doug Chapman wrote:
>>> but once again broken just yesterday by the following commit.  I have
>>> backed just this commit out and verified I no longer panic.
>> Hmm, the only way I can see this happening is if the hardware signals
>> an interrupt even though we've explicitly shut it off.  Does this patch
>> help? If it does help, does it produce the warning in dmesg?
>>
>> Thanks,
> 
> 
> The patch does fix the panic.  Here are all the e1000 messages from
> dmesg after a bootup.  Note that only eth0 is actually configured and
> connected:
> 
> 
> # dmesg | grep e1000
> e1000: 0000:01:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f8
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: 0000:01:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f9
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: 0000:15:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c4
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: 0000:15:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c5
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: Unexpected interrupt icr=0x4

that's indeed the link status change we fire manually to trigger the watchdog run:

#define E1000_ICR_LSC           0x00000004 /* Link Status Change */

Auke
