From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Mon, 25 Apr 2016 16:03:40 -0600
Message-ID: <571E943C.9010504@cumulusnetworks.com>
References: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
 <20160425.152611.583503438886577374.davem@davemloft.net>
 <571E72AA.4030100@cumulusnetworks.com>
 <20160425.164227.1599148827995063295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mmanning@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38035 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965020AbcDYWDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 18:03:48 -0400
Received: by mail-ig0-f169.google.com with SMTP id m9so75507244ige.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 15:03:47 -0700 (PDT)
In-Reply-To: <20160425.164227.1599148827995063295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/16 2:42 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon, 25 Apr 2016 13:40:26 -0600
>
>> It's unfortunate you want to take that action. Last week I came across
>> a prior attempt by Stephen to do this same thing -- keep IPv6
>> addresses. That prior attempt was reverted by commit
>> 73a8bd74e261. Cumulus, Brocade, and others clearly want this
>> capability.
>
> But nobody has implemented it correctly, it doesn't matter who wants
> the feature.  That's why it keeps getting reverted.
>
> Also, this testing you are talking about should have happened long
> before you submitted that first patch that introduced all of these
> regressions.  My observations tell me that the bulk of the testing
> happened afterwards and that's why all the regressions are popping up
> now.
>

My testing when submitting the patch was host level: Add an address, 
while(1) (link up, link down), delete an address, etc.

Once it was committed to our kernel it started getting hit with a range 
of L3 deployment scenarios with many nodes and networking config files 
are uploaded and jumped between on real switch hardware - no reboot but 
'networking reload' on the fly. Jumping between different deployments 
with different sets addresses, routes, vrf devices, bridges, bonds, etc.

Your objection seems to be 'all these regressions' but beyond the ref 
count from Andrey all of the bug reports have come from me with 1 from 
Mike, another invested party wanting this to happen. I am the one who 
spent the hours dealing with the kernel panics. My patch, my bug, my 
time wasted coming up with the delta patch. Rather than focusing on my 
mistakes, why not see the commitment on following through with this change?
