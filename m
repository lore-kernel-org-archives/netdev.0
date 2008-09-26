From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Fri, 26 Sep 2008 21:50:24 +0200
Message-ID: <20080926195024.GA2548@ami.dom.local>
References: <20080926031832.GA27289@minyard.local> <20080926040917.GB7209@linux.vnet.ibm.com> <48DCE874.8070704@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:19946 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbYIZTt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:49:58 -0400
Received: by nf-out-0910.google.com with SMTP id d3so423512nfc.21
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2008 12:49:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48DCE874.8070704@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2008 at 08:49:40AM -0500, Corey Minyard wrote:
...
> I don't believe udp_disconnect() releases the socket.   
> sk_common_release() seems to be the place where the refcount is  
> decremented.  But wherever it is done, it would have to be after the 
> unhash.

...Which, BTW, could be repeated then, so hlist_del_init() matters
yet. (Another sign of such possibility should be this "if ()" in
udp_lib_unhash().)

Jarek P.
