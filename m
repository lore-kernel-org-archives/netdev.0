From: David Miller <davem@davemloft.net>
Subject: Neptune regression...
Date: Sat, 03 May 2008 23:52:12 -0700 (PDT)
Message-ID: <20080503.235212.140840235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matheos.worku@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752098AbYEDGwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 02:52:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Matheos, this patch of your's:

commit 7f7c4072ea552f97a0898331322f71986a97299c
Author: Matheos Worku <matheos.worku@sun.com>
Date:   Thu Apr 24 21:02:37 2008 -0700

    niu: Determine the # of ports from the card's VPD data
    
    [ Fix minor whitespace and coding style stuff... -DaveM ]
    
    Signed-off-by: Matheos Worku <matheos.worku@sun.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Breaks on-board Neptune chips on Maramba systems.

Previously the code in niu_get_and_validate_port() used a default of
"4" ports if the various probing methods failed.  Your code removed
that fallback.

This case seems to be what triggers for on-board Maramba chips.

So, for now, I'm going to put the:

	if (!parent->num_ports)
		parent->num_ports = 4;

back in there to fix the regression.  I've validated that this fixes
the problem.

Is there some other mechanism we should be using here to detect the
port count in the Maramba on-board case?
