From: Arvid Brodin <Arvid.Brodin@xdin.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Wed, 11 Apr 2012 14:39:57 +0000
Message-ID: <4F859868.8090808@xdin.com>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
 <4F7CD4BC.4000006@enea.com>
 <20120404165559.5223ab95@s6510.linuxnetplumber.net>
 <20120404.202109.2046106039992811660.davem@davemloft.net>
 <4F7F10FC.3020308@enea.com> <1333731991.3282.17.camel@deadeye>
 <20120406111912.172bb1fb@nehalam.linuxnetplumber.net>
 <4F84CA36.7020209@xdin.com>
 <20120410182847.45e47c5e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:49350 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab2DKOmv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 10:42:51 -0400
In-Reply-To: <20120410182847.45e47c5e@nehalam.linuxnetplumber.net>
Content-Language: en-US
Content-ID: <C39165802385D44C9EDEDCFA01B43987@redbull.xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-04-11 03:28, Stephen Hemminger wrote:
> 
>> 3) My feeble suggestion to cast icmp_hdr() to (char *) is of course even worse (it doesn't
>> even avoid the erroneous cast in the first place).
>>
>> So what do we do?
>>
> 
> Reading Documentation/unalgined-memory-access.txt suggests that you
> probably should copy the skb before passing up the stack (if necessary).
> That is safe (but slightly slower).

Ok, so my patch does the right thing then? I.e. if no HAVE_EFFICIENT_UNALIGNED_ACCESS and
the user does not choose to pad the HSR tag (with NONSTANDARD_HSR), we memmove the payload
(look in hsr_rcv()).

Or do you want me to remove the option to pad the HSR tag to get rid of the memmove if we
don't HAVE_EFFICIENT_UNALIGNED_ACCESS?

-- 
Arvid Brodin
Enea Services Stockholm AB - since February 16 a part of Xdin in the Alten Group. Soon we
will be working under the common brand name Xdin. Read more at www.xdin.com.