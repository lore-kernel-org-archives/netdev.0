From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Fri, 18 May 2007 10:47:44 -0700
Message-ID: <464DE6C0.7050505@intel.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: David Acker <dacker@roinet.com>, Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50448 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152AbXERRsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 13:48:10 -0400
In-Reply-To: <464DDE3E.9010400@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Acker wrote:
> Kok, Auke wrote:
>> First impression just came in: It seems RX performance is dropped to 
>> 10mbit. TX is unaffected and runs at 94mbit/tcp, but RX the new code 
>> seems to misbehave and  fluctuate, dropping below 10mbit after a few 
>> netperf runs and staying there...
>>
>> ideas?
> 
> I found the problem.  Another casualty of working with two different kernels at once...arg.
> The blank rfd needs to have its el-bit clear now.  Here is the new and improved patch.


> -	nic->blank_rfd.command = cpu_to_le16(cb_el & cb_s);
> +	nic->blank_rfd.command = 0;

OK, that fixed it and it's getting 94mbit/tcp rx now without issues. Milton, can 
you look at this patch? I'd like some more feedback. Meanwhile I will try to get 
this tested on a variety of e100 NICs, which will take a few days.

Thanks,

Auke
