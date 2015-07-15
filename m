From: "Cantavenera, Giuseppe (EXT-Other - DE/Ulm)"
	<giuseppe.cantavenera.ext@nokia.com>
Subject: RE: [RFC net-next] xfrm: refactory to avoid state tasklet
 scheduling errors
Date: Wed, 15 Jul 2015 14:33:28 +0000
Message-ID: <362FEC998FA6CC42BC5BA5B7BA75E0970D5C6CAE@DEMUMBX009.nsn-intra.net>
References: <1436254997-2942-1-git-send-email-giuseppe.cantavenera@azcom.it>
 <5A90DA2E42F8AE43BC4A093BF0678848E797EE@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Sverdlin, Alexander (Nokia - DE/Ulm)" <alexander.sverdlin@nokia.com>,
	"Glavinic-Pecotic, Matija (EXT-Other - DE/Ulm)"
	<matija.glavinic-pecotic.ext@nokia.com>,
	"Faustini, Nicholas (EXT-Other - DE/Ulm)"
	<nicholas.faustini.ext@nokia.com>
To: "ext Du, Fan" <fan.du@intel.com>,
	Giuseppe Cantavenera <giuseppe.cantavenera@azcom.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:42598 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbGOOdr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 10:33:47 -0400
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848E797EE@SHSMSX104.ccr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: ext Du, Fan [mailto:fan.du@intel.com]
>Sent: Tuesday, July 14, 2015 9:53 AM
>To: Giuseppe Cantavenera; netdev@vger.kernel.org
>Cc: Steffen Klassert; David S. Miller; Sverdlin, Alexander (Nokia -
>DE/Ulm); Glavinic-Pecotic, Matija (EXT-Other - DE/Ulm); Cantavenera,
>Giuseppe (EXT-Other - DE/Ulm); Faustini, Nicholas (EXT-Other - DE/Ulm);
>Du, Fan
>Subject: RE: [RFC net-next] xfrm: refactory to avoid state tasklet
>scheduling errors
>
>
>
>>-----Original Message-----
>>From: Giuseppe Cantavenera [mailto:giuseppe.cantavenera@azcom.it]
>>Sent: Tuesday, July 7, 2015 3:43 PM
>>To: netdev@vger.kernel.org
>>Cc: Giuseppe Cantavenera; Steffen Klassert; David S. Miller; Du, Fan;
>Alexander
>>Sverdlin; Matija Glavinic Pecotic; Giuseppe Cantavenera; Nicholas
>Faustini
>>Subject: [RFC net-next] xfrm: refactory to avoid state tasklet
>scheduling errors
>>Hello,
>>
>>we also meet the same bug Fan Du did a while ago.
>>Two solutions were proposed in the past:
>>either forcibly mark as expired all of the keys every time the clock is
>set,
>>or replace the existing timers with relative ones.
>>
>>The former would introduce unexpected behaviour
>>(the keys would keep expiring when they shouldn't) and does not address
>the
>>real problem: THE COUPLING between the SA scheduling and the wall
>timer.
>>Actually it introduces even more of that.
>>
>>The latter is robust, extremly lightweight and maintanable, and
>preserves the
>>expected behaviour, that's why we preferred it.
>>
>>Any feedback or any other idea is greatly appreciated.
>
>Thanks for keep working this issue as I did 2 years ago.
>
>Objection against the original approach from the maintainers is that it
>complicates
>the logic to the degree which involving extra maintenance effort, that
>is the effort
>it's not worthwhile against the trouble it might introduce in the
>future.
>
>Another approach you can try is using monotonic boot time(counting in
>suspend time also)
>to mark the life time of SA, then the timer handler logic will be quite
>easier and smaller
>than now, sure it will be robust naturally. The cost is that SA lifetime
>displaying by setkey
>and SA migration has to be taken care of as SA life time is boot time
>now, not the wall time.


Hi Fan Du, 
 Thanks for your feedback.

It can probably work that way.
I think we can wait if someone else has any further comments,
then maybe try to see how it works.

Thanks,
Giuseppe
