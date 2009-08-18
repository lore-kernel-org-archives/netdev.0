From: "Gregory Haskins" <GHaskins@novell.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model
Date: Tue, 18 Aug 2009 06:36:07 -0600
Message-ID: <4A8A67F70200005A000528F8@sinclair.provo.novell.com>
References: <4A8A67ED0200005A000528F5@sinclair.provo.novell.com>
 <4A8A67F70200005A000528F8@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <mingo@elte.hu>, <gregory.haskins@gmail.com>,
	<alacrityvm-devel@lists.sourceforge.net>, <mst@redhat.com>,
	<kvm@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758876AbZHRMgK@vger.kernel.org>
In-Reply-To: <4A8A67F70200005A000528F8@sinclair.provo.novell.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yeah, I agree.  I am not advocating we expend energy on this now.  But my thoughts at the time were that that particular problem can be solved at io-setup time with some kind of call to qualify the address.

Iow: a slow path call with the address would return flags on whether iowrite() should do a real io, or a IOoHC.

-greg
 
-----Original Message-----
From: Avi Kivity <avi@redhat.com>
To: Gregory Haskins <GHaskins@novell.com>
Cc:  <mingo@elte.hu>
Cc:  <gregory.haskins@gmail.com>
Cc:  <alacrityvm-devel@lists.sourceforge.net>
Cc:  <mst@redhat.com>
Cc:  <kvm@vger.kernel.org>
Cc:  <linux-kernel@vger.kernel.org>
Cc:  <netdev@vger.kernel.org>

Sent: 8/18/2009 6:29:08 AM
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model	 for

On 08/18/2009 03:24 PM, Gregory Haskins wrote:
> (Again on the top post)
>
> No, Avi, nothing has changed to my knowledge.  I just saw that you and Michael were heading down the same path, so I thought I might interject that we've already covered that ground.
>
> As of right now, I am of the opinion that its not worth any change in the short term, and may be worth IOoHC in the long term (primarily so that mmios get a boost)
>    

The primary issue with IOoHC is that while hypercalls are faster than 
emulated mmio, they're much slower than assigned mmio.  So we have to 
distinguish between these two cases, which gets kinda icky.

-- 
error compiling committee.c: too many arguments to function
