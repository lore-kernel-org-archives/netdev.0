From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH] tipc: checking returns and Re: Possible Circular Locking
 in TIPC
Date: Thu, 04 Jan 2007 16:16:20 +0000
Message-ID: <459D2854.1000405@ericsson.com>
References: <20061228121702.GA5076@ff.dom.local> <459C396B.1090508@ericsson.com> <20070104122843.GC3175@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn <snakebyte@gmx.de>,
	Per Liden <per.liden@ericsson.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"'tipc-discussion@lists.sourceforge.net'"
	<tipc-discussion@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:58404 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965011AbXADQQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 11:16:55 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070104122843.GC3175@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Regards
///jon

Jarek Poplawski wrote:

>
>I know lockdep is sometimes
>too careful but nevertheless some change is needed
>to fix a real bug or give additional information
>to lockdep. 
>  
>
I don't know lockdep well enough yet, but I will try to find out if that
is possible.

>  
>
>>>Btw. there is a problem with tipc_ref_discard():
>>>it should be called with tipc_port_lock, but
>>>how to discard a ref if this lock can't be
>>>acquired? Is it OK to call it without the lock
>>>like in subscr_named_msg_event()?
>>>
>>>
>>>      
>>>
>>I suspect you are mixing up things here. 
>>We are handling two different reference entries and two
>>different locks in this function.
>>One reference entry points to a subscription instance, and its
>>reference (index) is obtainable from subscriber->ref. So, we
>>could easily lock the entry if needed. However, in this
>>particular case it is unnecessary, since there is no chance that
>>anybody else could have obtained the new reference, and
>>hence no risk for race conditions.
>>The other reference entry was intended to point to a new port,
>>but, since we didn't obtain any reference in the first place,
>>there is no port to delete and no reference to discard.
>>    
>>
>
>I admit I don't know this program and I hope I
>didn't mislead anybody with my message. I only
>tried to point at some doubts and maybe this
>function could be better commented about when
>the lock is needed.
>  
>
Agreed.

>Thanks for explanations & best regards,
>
>Jarek P.
>
>  
>

