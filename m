From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: inet_diag insufficient validation?
Date: Wed, 01 Jun 2011 11:40:49 -0400
Message-ID: <1306942849.3150.10.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57633 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab1FAPk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 11:40:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems to me that the auditing performed by inet_diag_bc_audit() is
insufficient to prevent pathological INET_DIAG bytecode from doing bad
things.

Firstly, it's possible to cause an infinite loop in inet_diag_bc_audit()
with a INET_DIAG_BC_JMP opcode with a "yes" value of 0.  The valid_cc()
function, also called from here, seems suspicious as well.

Once the bytecode is actually run in inet_diag_bc_run(), it looks like
more infinite loops are possible, if appropriate "yes" or "no" values
are set to zero and weren't validated by the audit.

Finally, I can't seem to find any validation that the reported length of
the netlink message header doesn't exceed the skb length, as checked in
some other netlink receive functions, which could result in reading
beyond the bounds of the socket data.  I could just be missing something
here though.

Regards,
Dan

