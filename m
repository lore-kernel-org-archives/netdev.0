From: David Daney <ddaney@caviumnetworks.com>
Subject: Weird locking in __release_sock()?
Date: Wed, 22 Jun 2011 16:31:13 -0700
Message-ID: <4E027B41.3040009@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19653 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757427Ab1FVXbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 19:31:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In net/core/sock.c the function __release_sock() appears to drop the 
socket lock, and then feed the backlogged skbs to sk_backlog_rcv().


In the case of an IPv4 TCP socket, sk_backlog_rcv() calls 
tcp_v4_do_rcv(), which is documented like this:

/* The socket must have it's spinlock held when we get
  * here.
.
.
.
*/

Q: How can this be correct?

Perhaps I am missing something.  In any event, thanks in advance 
shedding some light on the locking situation.

David Daney
