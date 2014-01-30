From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 16:48:41 -0500
Message-ID: <52EAC8B9.2070906@pobox.com>
References: <Pine.LNX.4.44L0.1401301630340.31548-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Freddy Xin <freddy@asix.com.tw>
To: Alan Stern <stern@rowland.harvard.edu>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:64906 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbaA3Vsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 16:48:43 -0500
In-Reply-To: <Pine.LNX.4.44L0.1401301630340.31548-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-30 04:43 PM, Alan Stern wrote:
> On Thu, 30 Jan 2014, Sarah Sharp wrote:
> 
>> It should not matter what alignment or length of scatter-gather list the
>> upper layers pass the xHCI driver, it should just work.  I want to do
>> this fix right, by changing the fundamental way we queue TRBs to the
>> rings to fit the TD rules.  We should break each TD into fragment-sized
>> chunks, and add a link TRB in the middle of a segment where necessary.
> 
> That's a good plan.  However _some_ restriction will turn out to be
> necessary.
> 
> For example, what will you do if a driver submits an SG list containing
> 300 elements, each 3 bytes long?

Allocate a contiguous (bounce) buffer and copy the fragments to/from it?

-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
