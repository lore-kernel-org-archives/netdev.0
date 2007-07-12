From: James Morris <jmorris@namei.org>
Subject: TCP stalls in current git, possibly splice related
Date: Thu, 12 Jul 2007 16:12:25 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707121608100.10773@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:37778 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbXGLUM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 16:12:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm seeing TCP connection stalls with current git, and a bisect found the 
following as a possible cause:

534f2aaa6ab07cd71164180bc958a7dcde41db11 is first bad commit
commit 534f2aaa6ab07cd71164180bc958a7dcde41db11
Author: Jens Axboe <jens.axboe@oracle.com>
Date:   Fri Jun 1 14:52:37 2007 +0200

    sys_sendfile: switch to using ->splice_read, if available
    
    This patch makes sendfile prefer to use ->splice_read(), if it's
    available in the file_operations structure.
    
    Signed-off-by: Jens Axboe <jens.axboe@oracle.com>


It's a large patch, and not clear if it's the patch itself or coincidental 
to it.

I've looked at some tcpdumps, but may not be able to get back to them 
until tomorrow or the weekend, & thought it might be useful to get the 
report out now.



- James
-- 
James Morris
<jmorris@namei.org>
