From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NET: Remove unneeded type cast in skb_truesize_check()
Date: Mon, 05 Nov 2007 18:59:26 -0500
Message-ID: <472FAE5E.8030701@oracle.com>
References: <20071102191426.30464.7490.stgit@manray.1015granger.net> <20071102.142717.157261554.davem@davemloft.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070500030505000507020301"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:54630 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbXKFAAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 19:00:43 -0500
In-Reply-To: <20071102.142717.157261554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070500030505000507020301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> Date: Fri, 02 Nov 2007 15:14:26 -0400
> 
>> The (int) type cast in skb_truesize_check() is unneeded: without it, all
>> the variable types in the conditional expression are unsigned integers.  As
>> it stands, the type cast causes a comparison between a signed and an
>> unsigned integer, which can produce unexpected results.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> 
> This is checking for skb->truesize being decremented too much by other
> code, which could cause a wraparound below zero, so we do want
> negaitve checks here.

If that's truly the case, document the requirement (perhaps using
something the compiler itself can verify) instead of using a clever
type cast trick.

Here's the problem with leaving these little surprises in commonly used 
kernel headers.  Suppose the developer of a network driver or network 
file system that uses one of these headers wants to employ static code 
analysis to identify issues introduced by new patches to their 
subsystem.  The tool warnings generated in kernel headers are just 
noise, and make using such code analysis difficult.

--------------070500030505000507020301
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
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070500030505000507020301--
