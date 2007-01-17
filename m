From: Brandon Craig Rhodes <brandon@rhodesmill.org>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Wed, 17 Jan 2007 12:38:44 -0500
Message-ID: <87odox4kpn.fsf@ten22.rhodesmill.org>
References: <87bqky759v.fsf@ten22.rhodesmill.org>
	<87mz4h61p0.fsf@ten22.rhodesmill.org> <45AE5B8C.2070407@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-23-211-138.clients.speedfactory.net ([66.23.211.138]:42497
	"EHLO ten22.rhodesmill.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932600AbXAQRip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 12:38:45 -0500
To: Larry Finger <larry.finger@lwfinger.net>
In-Reply-To: <45AE5B8C.2070407@lwfinger.net> (Larry Finger's message of "Wed,
	17 Jan 2007 11:23:24 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger <larry.finger@lwfinger.net> writes:

> Brandon Craig Rhodes wrote:
>
>> Having further reviewed my code, I have changed my mind; the
>> ieee80211_crypt_tkip routines are not designed to be responsible for
>> creating enough headroom and tailroom.  The "hostap" driver should be
>> doing this.
>
> This makes sense. I have used the bcm43xx driver with WPA-PSK TKIP
> encryption for at least a year, and I have never seen this error.

>From what I can tell, even people using the "hostap" driver never see
this error!  The kernel must allocate such large skb's in normal
operation that there is always more than enough tailroom for twelve
bytes of TKIP encryption.

In my case, packets are arriving on the physical machine from a Xen
virtual machine that the physical machine is hosting.  The Xen code
receiving the packets must allocate much tighter skb's than does the
normal kernel code that receives packets from hardware.  (Perhaps
because Xen knows the packet size ahead of time, whereas hardware
drivers do not?)  Searching for the error message:

 kernel: Invalid packet for Michael MIC add (tailroom=6 hdr_len=24 skb->len=92)

on Google returned, if I recall, only references to the kernel source
code itself - which always gives me the sinking feeling that I've
gotten myself into a configuration shared with no one else on earth!

-- 
Brandon Craig Rhodes   brandon@rhodesmill.org   http://rhodesmill.org/brandon
