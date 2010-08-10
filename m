From: Philip Rakity <prakity@marvell.com>
Subject: Re: [PATCH v2]  net: add Fast Ethernet driver for PXA168.
Date: Tue, 10 Aug 2010 09:24:23 -0700
Message-ID: <7B1965FC-E61F-4BFD-86B1-F9D390A012CC@marvell.com>
References: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com>
 <FE9BFA4C-11AB-46B9-A514-EB62467A1BB7@marvell.com>
 <1281429004.17990.2.camel@pe-lt522.marvell.com>
 <20100810123329.GR8876@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sachin Sanap <ssanap@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dakia3.marvell.com ([65.219.4.28]:33179 "EHLO
	dakia3.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932370Ab0HJQhR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 12:37:17 -0400
In-Reply-To: <20100810123329.GR8876@mail.wantstofly.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Aug 10, 2010, at 5:33 AM, Lennert Buytenhek wrote:

> On Tue, Aug 10, 2010 at 02:00:04PM +0530, Sachin Sanap wrote:
> 
>> * Headroom in SKB for 802.11 not included in the patch since that
>>  varies based on 802.11 a/b/g/n.
> 
> I don't think this is true?
> 
> (The 11a/b/n on-the-air preambles are of different lengths (and are
> sent at different rates), but that isn't visible to software.)
> 
> 


802.11b/g headers are larger and if not handled by firmware in an offload engine are programmed by the driver.  There needs to be room for 

a) Frame Control (2 bytes)
b) AID (2 bytes)
c) address-1 (6 bytes)
d) address-2 (6 bytes)
e) address-3 (6 bytes)
f) seqfrag  (2 bytes)
g) address-4 (6 bytes) 


or 30 bytes. 11n needs more.  Some of these fields ARE visible to s/w.  So the skb prepend area needs to be larger when sending from ethernet to wifi since there will not be room for some of these fields.

Philip


<snip> 