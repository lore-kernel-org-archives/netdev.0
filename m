From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v3 2/2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Fri, 25 Sep 2015 09:25:15 -0400
Message-ID: <f7t4mii1vic.fsf@aconole.bos.csb>
References: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
	<1442881622-11316-3-git-send-email-aconole@bytheb.org>
	<20150924.121459.1016780653505420756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:33827 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756626AbbIYNZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 09:25:19 -0400
Received: by qgez77 with SMTP id z77so69127400qge.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 06:25:18 -0700 (PDT)
In-Reply-To: <20150924.121459.1016780653505420756.davem@davemloft.net> (David
	Miller's message of "Thu, 24 Sep 2015 12:14:59 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for your time and the review.

David Miller <davem@davemloft.net> writes:
> From: Aaron Conole <aconole@bytheb.org>
> Date: Mon, 21 Sep 2015 20:27:02 -0400
>
>> +			goto unlock;
>
> Sorry, I don't want to see goto's from one loop into a completely
> different one.

I think you misread. This goto does not do that; it goes from the else 
side of one if block, into a different if block within the same do/while
pair. I assumed this was okay, because in 
commit:b48732e4a48d80ed4a14812f0bab09560846514e the same type of goto
unlock jump is used. Since that commit was accepted 4 months ago, I
figured the style hadn't changed. 

Would you rather see:
+			unix_state_unlock(sk);
+			break;

> The XXX comment is probably not appropriate either.

Agreed, any v4 post will not include it.
