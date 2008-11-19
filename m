From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example
	implementation
Date: Wed, 19 Nov 2008 13:39:29 +0100
Message-ID: <1227098369.16263.39.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly>
	 <491B23FE.9000105@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16722 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751918AbYKSMjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:39:33 -0500
In-Reply-To: <491B23FE.9000105@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 18:44 +0000, Oliver Hartkopp wrote:
> I really wondered if you posted the series to get an impression why 
> adding a new field is a good idea ;-)

Oh dear, my secret plan has been revealed ;-) No, I was really hoping
that the patch would be acceptable. After rewriting the patch series
with one additional field the code is simpler (or so I hope). I just
posted it to linux-kernel and linux-net.

> I would also vote for having a new field in the 
> skb instead of this current 'bit-compression' approach which smells 
> quite expensive at runtime and in code size. Not talking about the 
> mentioned potential locking issues ...

The locking issues still remain: the hardware reconfiguration in the
ioctl needs to be coordinated with the ongoing time stamping. Then
there's the raw2sys callback which is made by the socket layer into the
device. That one is problematic also because finding that device isn't
as easy as I thought (see my other mails), so perhaps we should get rid
of the delayed transformation and add two fields.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

