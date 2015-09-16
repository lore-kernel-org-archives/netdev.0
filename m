From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Initialize table in fib result
Date: Wed, 16 Sep 2015 10:04:30 -0600
Message-ID: <55F9930E.5060305@cumulusnetworks.com>
References: <1442417925-51597-1-git-send-email-dsa@cumulusnetworks.com>
 <55F99115.3020307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sergey.senozhatsky.work@gmail.com, richard.alpe@ericsson.com,
	festevam@gmail.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34849 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbIPQEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 12:04:33 -0400
Received: by pacfv12 with SMTP id fv12so217261421pac.2
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 09:04:33 -0700 (PDT)
In-Reply-To: <55F99115.3020307@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/16/15 9:56 AM, Nikolay Aleksandrov wrote:
> Just to have it documented: I don't think we need the second NULLing,
> but it doesn't hurt.

I think we do. After the second one there is a goto to local_input which 
uses res.table. The second goto is reachable 'if 
!IN_DEV_FORWARD(in_dev)' in which case res.table is valid but should not 
be. In short if fi is reset, table should be.
