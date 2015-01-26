From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: improve error handling when a remote
 crashes
Date: Mon, 26 Jan 2015 15:29:46 -0500
Message-ID: <54C6A3BA.3060004@oracle.com>
References: <54C6911B.5040501@oracle.com> <20150126195403.GE6437@oracle.com> <54C6A154.3090906@oracle.com>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48607 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbbAZU3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:29:48 -0500
In-Reply-To: <54C6A154.3090906@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2015 03:19 PM, David L Stevens wrote:

>> I think you'll have a higher reclaim rate for finding !READY if you
>> started at dr->cons instead: dr->cons is the one that was last ACK'ed,
>> and that ack would only have been sent after the peer had marked the
>> descriptor as DONE. (consumer would have had a chance to read more
>> descriptors, by the time the tx-reclaim loop goes around)
   :
> The descriptors indices we look at are unchanged by this patch.

Understood, and what I suggested was an optimization for tx-reclaim.


> 	It should only happen if there is active traffic when a remote
> crashes, but if a remote is giving us garbage in other cases, I think an
> admin would want to check that out.

This allows one DomU to spam up everyone else's log file by crashing
periodically.

In any case, the contents of the message do not in any way suggest
that an admin (of the DomU, who probably has no control over
other DomU's anyway) should go and baby-sit some other DomU that
just crashed.

ymmv.

--Sowmini
