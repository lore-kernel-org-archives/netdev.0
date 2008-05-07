From: Marin Mitov <mitov@issp.bas.bg>
Subject: CONFIG_HIGHMEM or CONFIG_HIGHMEM64G in illegal_highdma()
Date: Wed, 7 May 2008 19:49:54 +0300
Message-ID: <200805071949.54583.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.issp.bas.bg ([195.96.236.10]:45727 "EHLO mail.issp.bas.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747AbYEGQt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 12:49:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

The usage of NETIF_F_HIGHDMA in drivers/net/* make me think its 
purpose is to declare drivers's capability to address RAM above 4GB, OK?

For x86_64 CONFIG_HIGHMEM is not defined, so the function 
illegal_highdma() found in net/core/dev.c returns 0 because 
x86_64 has IOMMU mapping all RAM.

For x86_32 CONFIG_HIGHMEM is defined as 
(CONFIG_HIGHMEM4G || CONFIG_HIGHMEM64G)
While CONFIG_HIGHMEM4G insures RAM is bellow 4GB some checks
are unnecessarily done. 

Should we have CONFIG_HIGHMEM64G in illegal_highdma()
instead of CONFIG_HIGHMEM? If so should I post a patch?

Regards.

Marin Mitov

P.S. This is a resend, due to recent problems with http://lkml.org/
