From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: PROBLEM: tg3 spitting out uninitialized memory
Date: Sun, 15 Apr 2007 23:25:56 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC09400A0@nt-irva-0751.brcm.ad.broadcom.com>
References: <461FC32C.4060309@jwebb.sygneca.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Andi Kleen" <andi@firstfloor.org>, netdev@vger.kernel.org
To: "Jamie webb" <j@jwebb.sygneca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4970 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932179AbXDPG0V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 02:26:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <461FC32C.4060309@jwebb.sygneca.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamie webb wrote:

> 
> Well, so far so good. I'll let you know if it happens again, but it 
> looks like that's fixed it.
> 
> Further testing showed that I also had to disable rx checksumming, 
> otherwise I was getting random kernel crashes. Presumably it was not 
> only reading data from random memory locations, but also 
> writing in the 
> wrong place...
> 
> So, do I understand correctly that this is causing the CPU 
> rather than 
> the NIC to do the checksumming?

That's right.  See the discussion on a similar problem here:

<http://forums1.itrc.hp.com/service/forums/questionanswer.do?threadId=10
59644&admit=-682735245+1158251313899+28353475>

In this other case, the symptoms were very similar to yours.
I suspected it was an IOMMU problem, and the problem went
away when the user upgraded to the latest kernel at that
time.

> 
> Is this a reasonable permanent solution?
> 

I don't think so.  We need to get to the bottom of it.
Looking at your original email, the corruption also happened
in multiples of 16 bytes.  If it is a hardware or driver bug,
the corruption is usually more random than this.  Or MSS-
sized chunks should be corrupted.  If you have other captured
corruption data, please send it to me.

Anyway, I'll see if our lab can setup a similar machine to
test this out.  Thanks.

> Crashing aside, I'm a little nervous about putting into 
> production a box 
> that might for example randomly decide to serve up its SSL 
> private keys 
> halfway through an email message...
> 
> Cheers
> 
> /J
> 
> 
> 

