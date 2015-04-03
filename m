From: Joe Perches <joe@perches.com>
Subject: fib_trie: commit 95f60ea3e99a missing else?
Date: Fri, 03 Apr 2015 13:53:02 -0700
Message-ID: <1428094382.29510.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0096.hostedemail.com ([216.40.44.96]:33194 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752473AbbDCUxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 16:53:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexander.

commit 95f60ea3e99a ("fib_trie: Add collapse() and should_collapse() to resize")
changed this block from:

	if (a && !b)
		...
	else if (!a && b)
		...

to:

	if (a && !b)
		...
	if (!a && b)
		... 

Was there a reason for the "else" removal?

I notice that object code size increases a bit (x86-64)
if the else is put back.

net/ipv4/fib_trie.c
[]
@@ -375,11 +388,11 @@ static void put_child(struct tnode *tn, unsigned long i, s
 
        BUG_ON(i >= tnode_child_length(tn));
 
-       /* update emptyChildren */
+       /* update emptyChildren, overflow into fullChildren */
        if (n == NULL && chi != NULL)
-               tn->empty_children++;
-       else if (n != NULL && chi == NULL)
-               tn->empty_children--;
+               empty_child_inc(tn);
+       if (n != NULL && chi == NULL)
+               empty_child_dec(tn);
 
