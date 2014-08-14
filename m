From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 1/2] qlge: Fix compilation warning
Date: Thu, 14 Aug 2014 14:31:07 -0700 (PDT)
Message-ID: <20140814.143107.519984079758340157.davem@redhat.com>
References: <1407953289-23460-1-git-send-email-harish.patil@qlogic.com>
	<1407953289-23460-2-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	sudarsana.kalluru@qlogic.com
To: harish.patil@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754251AbaHNVbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:31:10 -0400
In-Reply-To: <1407953289-23460-2-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>
Date: Wed, 13 Aug 2014 14:08:08 -0400

> From: Harish Patil <harish.patil@qlogic.com>
> 
> Fix the below warning message observed during qlge compilation:
> qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function
> 
> Signed-off-by: Harish Patil <harish.patil@qlogic.com>

Please fix this differently.  The problem is that the compiler can't see that
you've done the !length check at the top of the function, so when it later
sees the while (length > 0) loop, it doesn't know that this loop will always
execute at least once.

Just change that loop to a do { } while() loop and the compiler will be able
to see everything.
