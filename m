From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NET: Remove unneeded type cast in skb_truesize_check()
Date: Wed, 07 Nov 2007 10:11:28 -0500
Message-ID: <4731D5A0.2090101@oracle.com>
References: <20071102191426.30464.7490.stgit@manray.1015granger.net>	<20071102.142717.157261554.davem@davemloft.net>	<472FAE5E.8030701@oracle.com> <20071105.163320.82203647.davem@davemloft.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040008090009090206080102"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26735 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbXKGPLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 10:11:36 -0500
In-Reply-To: <20071105.163320.82203647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040008090009090206080102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> Date: Mon, 05 Nov 2007 18:59:26 -0500
> 
>> If that's truly the case, document the requirement (perhaps using
>> something the compiler itself can verify) instead of using a clever
>> type cast trick.
> 
> Feel free to submit such a change.

Here's what I propose.

skb->truesize should be an int, not an unsigned int, since you expect 
that it may go below zero.

Explicitly assert that skb->truesize is greater than zero in 
skb_truesize_check().

Explicitly assert that skb->len + sizeof(sk_buff) is less than INT_MAX.

Leave the assertion that's already there, but ensure that the types on 
both side of the comparison are as we expect.

Thoughts?

>> Here's the problem with leaving these little surprises in commonly used 
>> kernel headers.  Suppose the developer of a network driver or network 
>> file system that uses one of these headers wants to employ static code 
>> analysis to identify issues introduced by new patches to their 
>> subsystem.  The tool warnings generated in kernel headers are just 
>> noise, and make using such code analysis difficult.
> 
> Here's the problem with submitting patches fixing non-bugs and
> removing useful assertions from kernel.  I won't apply them.

"removing useful assertions"

The (int) type cast in that assertion is nothing more than a comment. 
The compiler promotes that side of the comparison to match the type on 
the right side, and the explicit type cast is entirely ignored.  So in 
fact, my patch removed nothing but a mistaken assumption.  The assertion 
behaves the same after my patch as it did before.

Thus anyone might be confused at what exactly was being asserted in 
skb_truesize_check().  It's not a question of whether or not I reviewed 
the logic that uses skb->truesize before crafting my patch; I did review 
it.  The fact that skb_truesize_check() never before asserted that 
skb->truesize is greater than zero is not my fault.

--------------040008090009090206080102
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------040008090009090206080102--
