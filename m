From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Wed, 21 Aug 2013 12:38:15 -0700
Message-ID: <1377113895.1936.50.camel@joe-AO722>
References: <521504E1.5060309@xdin.com> <1377111680.1936.45.camel@joe-AO722>
	 <52150F95.7060004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arvid Brodin <arvid.brodin@xdin.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	David Miller <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39843 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752069Ab3HUTiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 15:38:16 -0400
In-Reply-To: <52150F95.7060004@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 23:05 +0400, Sergei Shtylyov wrote:
> On 08/21/2013 11:01 PM, Joe Perches wrote:
> >> High-availability Seamless Redundancy ("HSR") provides instant failover
> >> redundancy for Ethernet networks. It requires a special network topology where
> >> all nodes are connected in a ring (each node having two physical network
> >> interfaces). It is suited for applications that demand high availability and
> >> very short reaction time.

Hi back.

> >> +	if (likely(res1 == NET_XMIT_SUCCESS || res1 == NET_XMIT_CN ||
> >> +		   res2 == NET_XMIT_SUCCESS || res2 == NET_XMIT_CN)) {
> 
> > This might be faster using | instead of ||
> 
>     Doesn't || use shortcut evaluation in C? I.e. if the 1st == evaluates to 
> true, other comparisons are not even done.

Yes it does.

But if the 1st 3 comparisons are false and the
last comparison is true then those 3 tests and 
jumps are also done which takes additional
branch predictions paths.  Oring is fast.
