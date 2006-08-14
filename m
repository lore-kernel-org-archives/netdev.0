From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] zd1211rw: Support AL7230B RF
Date: Mon, 14 Aug 2006 20:39:58 +0100
Message-ID: <44E0D18E.9030407@gentoo.org>
References: <20060812165946.27E418E776D@zog.reactivated.net> <20060814191314.GC13934@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:8812 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932674AbWHNT32 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 15:29:28 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060814191314.GC13934@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Sat, Aug 12, 2006 at 05:59:46PM +0100, Daniel Drake wrote:
> 
>> +	/* All of these writes are identical to AL2230 unless otherwise
>> +	 * specified */
>> +	static const struct zd_ioreq16 ioreqs_1[] = {
>> +		/* This one is 7230-specific, and happens before the rest */
>> +		{ CR240,  0x57 },
>> +		{ },
> 
> I'm just curious about this line...what does it do for you?  A delay
> of some sort?

The hardware allows us to write to multiple registers in a single 
command, which is what happens with those big arrays. If we include an 
empty element, it splits the request into 2 commands around the empty 
element.

Up until recently, the vendor driver did not use the multiple-register 
writes at all, it sent a separate USB command for every single register. 
Us doing them all in a single command is obviously much nicer but it 
leaves us uncertain of how safe this is, and as some writes are clearly 
separated from others in the vendor driver (i.e. by msleep calls, or by 
pointless/redundant phy locking), we play it safe by adding in the empty 
splitter elements.

A while ago I went over the ZD1211 AL2230 code in some detail, removing 
all the redundant parts and the splits which were not required for the 
device to work. Maybe someone will do the same for the new AL7230B code 
someday, I don't own one of those devices yet :)

For now, the code you see is almost identical to the vendor driver 
(which has started using multi-register-write for this RF).

Daniel

