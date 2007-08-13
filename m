From: David Greaves <david@dgreaves.com>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it, anyways?
 [compare with e.g. NBD + MD raid])
Date: Mon, 13 Aug 2007 13:43:55 +0100
Message-ID: <46C0520B.20804@dgreaves.com>
References: <200708121335.17267.a1426z@gawab.com> <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr> <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm> <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr> <20070812174549.GA2915@teal.hq.k1024.org> <46BFB6BB.80406@steeleye.com> <Pine.LNX.4.64.0708122016100.22470@asgard.lang.hm> <46C01052.4050708@dgreaves.com> <Pine.LNX.4.64.0708130127260.22470@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Clements <paul.clements@steeleye.com>,
	Jan Engelhardt <jengelh@computergmbh.de>,
	Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@vger.kernel.org
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:52200 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904AbXHMMn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 08:43:59 -0400
In-Reply-To: <Pine.LNX.4.64.0708130127260.22470@asgard.lang.hm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

david@lang.hm wrote:
>> Would this just be relevant to network devices or would it improve 
>> support for jostled usb and sata hot-plugging I wonder?
> 
> good question, I suspect that some of the error handling would be 
> similar (for devices that are unreachable not haning the system for 
> example), but a lot of the rest would be different (do you really want 
> to try to auto-resync to a drive that you _think_ just reappeared,
Well, omit 'think' and the answer may be "yes". A lot of systems are quite 
simple and RAID is common on the desktop now. If jostled USB fits into this 
category - then "yes".

> what 
> if it's a different drive? how can you be sure?
And that's the key isn't it. We have the RAID device UUID and the superblock 
info. Isn't that enough? If not then given the work involved an extended 
superblock wouldn't be unreasonable.
And I suspect the capability of devices would need recording in the superblock 
too? eg 'retry-on-fail'
I can see how md would fail a device but may now periodically retry it. If a 
retry shows that it's back then it would validate it (UUID) and then resync it.

> ) the error rate of a 
> network is gong to be significantly higher then for USB or SATA drives 
> (although I suppose iscsi would be limilar)

I do agree - I was looking for value-add for the existing subsystem. If this 
benefits existing RAID users then it's more likely to be attractive.

David
