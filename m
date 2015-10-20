From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Tue, 20 Oct 2015 15:47:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBBC7E7@AcuExch.aculab.com>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
 <20151018221958.1b7b9d0d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"prashant@broadcom.com" <prashant@broadcom.com>,
	"eddie.wai@broadcom.com" <eddie.wai@broadcom.com>,
	"huangjw@broadcom.com" <huangjw@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:56046 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbbJTPth convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 11:49:37 -0400
In-Reply-To: <20151018221958.1b7b9d0d@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger
...
> On Sat, 17 Oct 2015 00:21:44 -0400
> Michael Chan <mchan@broadcom.com> wrote:
> 
> > +static bool bnxt_vf_pciid(int idx)
> > +{
> > +	if (idx == BCM57304_VF || idx == BCM57404_VF)
> > +		return true;
> > +	return false;
> > +}
> > +
> 
> I prefer just returning result of logical operation
> rather than adding unnecessary if statement.
> And never use (signed) int when unsigned is the real
> data type. Also avoid any unnecessary expansion of 16 bit
> value.

Actually 16-bit (and 8-bit) values always have to be extended to 'int'
before any arithmetic operations.
On systems with 16-bit arithmetic instructions (like x86) the
compiler can only use them if it can determine that result would be
the same (as if they were extended).

This can mean a lot of extra instructions if you do arithmetic
on 16-bit values the compiler is holding in registers.

Similarly using 16-bit values as function parameters/results
can require additional masking instructions.

IMHO This really all means that you should use [unsigned] int for
local variables even when the domain of the value is known
to be much smaller.

	David
