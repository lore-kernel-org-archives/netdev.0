From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 5/5] net: sctp: fix and consolidate SCTP checksumming
 code
Date: Mon, 04 Nov 2013 11:10:12 -0500
Message-ID: <5277C6E4.4010604@gmail.com>
References: <1383130252-1515-1-git-send-email-dborkman@redhat.com> <1383130252-1515-6-git-send-email-dborkman@redhat.com> <527117C3.2080306@gmail.com> <52778EF6.4000801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:44835 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757Ab3KDQKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 11:10:19 -0500
In-Reply-To: <52778EF6.4000801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2013 07:11 AM, Daniel Borkmann wrote:
> On 10/30/2013 03:29 PM, Vlad Yasevich wrote:
>> On 10/30/2013 06:50 AM, Daniel Borkmann wrote:
> [...]
>> Daniel
>>
>> Here is a follow-on idea that might help even more.
>> What if we put a pointer to skb_checksum_ops() in the skb
>> somewhere (I was thinking of skb_shinfo).  Then
>> skb_checksum can simply use the data from there.  This would
>> allow us to get rid of all the special cases in SCTP that do
>> checksumming.  We can just set it to partial, set up the right
>> fields and let HW or SW always do the right thing.
>
> I need to think about this a bit. This would certainly have the
> negative side-effect of a higher skb->truesize usage and thus
> affecting memory accounting for everyone as we extend
> skb_shared_info.

You are talking a single pointer here...  The alternative
is to do a per-protocol table.

-vlad
