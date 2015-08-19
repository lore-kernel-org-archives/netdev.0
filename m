From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v2 0/3] add TSO / A-MSDU TX for iwlwifi
Date: Wed, 19 Aug 2015 15:07:09 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8250B6@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
 <1439993647.6610.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753375AbbHSPHc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:07:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

First, thank you a lot for your comments.

On 08/19/2015 05:14 PM, Eric Dumazet wrote:
> On Wed, 2015-08-19 at 15:59 +0300, Emmanuel Grumbach wrote:
> 
>> We could have enabled A-MSDU based on xmit-more, but the
>> rationale of using LSO is that when using pfifo-fast,
>> the Qdisc gets one packet and dequeues is straight away
>> which limits the possibility to get a lot of packets at
>> once. (Am I right here?).
> 
> No, you are not ;)
> 
> Key point for xmit_more is BQL being implemented in your driver.
> 
> Relevant code is in try_bulk_dequeue_skb()
> 

I'll look at it.
I was almost starting to implement that but then I thought with another
(good?) reason to use LSO. LSO gives me the guarantee that the packet is
directed to one peer, which might not be the case with xmit_more since
we have one Qdisc for several clients in case we are in AP mode.
Building an A-MSDU for several clients is not possible, at least not for
several client in the L2 (different MAC addresses).
LSO avoids this problem completely.
