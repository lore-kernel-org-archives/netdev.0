From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: Netchannles: first stage has been completed. Further ideas.
Date: Sat, 22 Jul 2006 06:23:46 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F17442A3@NT-SJCA-0751.brcm.ad.broadcom.com>
References: <44C0FD6F.5010601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:59922 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751346AbWGVNZ6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jul 2006 09:25:58 -0400
In-Reply-To: <44C0FD6F.5010601@candelatech.com>
Content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> Evgeniy Polyakov wrote:
>> On Thu, Jul 20, 2006 at 02:21:57PM -0700, Ben Greear
> (greearb@candelatech.com) wrote:
>> 
>>> Out of curiosity, is it possible to have the single producer logic
>>> if you have two+ ethernet interfaces handling frames for a single
>>> TCP connection?  (I am assuming some sort of multi-path routing
>>> logic...)
>> 
>> 
>> I do not think it is possible with additional logic like what is
>> implemented in softirqs, i.e. per cpu queues of data, which in turn
>> will be converted into skbs one-by-one.
> 
> Couldn't you have two NICs being handled by two separate
> CPUs, with both CPUs trying to write to the same socket queue?
> 
> The receive path works with RCU locking from what I
> understand, so a protocol's receive function must be re-entrant.

Wouldn't it be easier simply not have two NICs feed the
same ring? What packets end up in which ring is fully
controllable. On the rare occasion that a single connection
must be fed by two NICs a software merge of the two rings
would be far cheaper than having to co-ordinate between
producers all the time.

