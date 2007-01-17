From: Brandon Craig Rhodes <brandon@rhodesmill.org>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Tue, 16 Jan 2007 22:34:43 -0500
Message-ID: <877ivm72cs.fsf@ten22.rhodesmill.org>
References: <87bqky759v.fsf@ten22.rhodesmill.org>
	<20070117033931.GX35756@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-23-211-138.clients.speedfactory.net ([66.23.211.138]:37381
	"EHLO ten22.rhodesmill.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752004AbXAQDeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 22:34:44 -0500
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20070117033931.GX35756@gaz.sfgoth.com> (Mitchell Blank, Jr.'s
	message of "Tue, 16 Jan 2007 19:39:31 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr <mitch@sfgoth.com> writes:

> Brandon Craig Rhodes wrote:
>
>> +		if (unlikely(err || skb_tailroom(skb) < 4)) {
>> +			printk(KERN_DEBUG "Failed to increase tailroom"
>> +			       " for TKIP encrypt");
>> +			return err || -1;
>
> The "||" operator in C doesn't act the same way it does in perl and ruby.
> You're always returning 1 here.

Egads!  You are correct.

My intention was to preserve the value of "err" if an unsuccessful
value was returned by skb_padto(), and otherwise to return "-1" which
seemed the popular value used for errors elsewhere in the code.

 - Would the expression "err ? err : -1" have served me better?
 - Do error codes mean anything here, or should I simply say "return -1"?

-- 
Brandon Craig Rhodes   brandon@rhodesmill.org   http://rhodesmill.org/brandon
