From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 3 Jan 2011 19:25:38 -0800
Message-ID: <AANLkTimFArsv1gF2BJabvbbQujpHdPC=bO204wkMbR_Z@mail.gmail.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
	<AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
	<20110103.110244.183045594.davem@davemloft.net>
	<1294083039.3167.184.camel@localhost>
	<4D2228E0.9030908@intel.com>
	<1294085724.3167.202.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:27646 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab1ADDZm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 22:25:42 -0500
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p043PeaH019923
	for <netdev@vger.kernel.org>; Mon, 3 Jan 2011 19:25:40 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by hpaq2.eem.corp.google.com with ESMTP id p043PcSt027647
	for <netdev@vger.kernel.org>; Mon, 3 Jan 2011 19:25:39 -0800
Received: by pvg7 with SMTP id 7so5392351pvg.25
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 19:25:38 -0800 (PST)
In-Reply-To: <1294085724.3167.202.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> The general idea is to at least keep the traffic local to one TX/RX
>> queue pair so that if we cannot match the queue pair to the applicat=
ion,
>> perhaps the application can be affinitized to match up with the queu=
e
>> pair. =A0Otherwise we end up with traffic getting routed to one TX q=
ueue
>> on one CPU, and the RX being routed to another queue on perhaps a
>> different CPU and it becomes quite difficult to match up the queues =
and
>> the applications.
>
> Right. =A0That certainly seems like a Good Thing, though I believe it=
 can
> be implemented generically by recording the RX queue number on the
> socket:
>
> http://article.gmane.org/gmane.linux.network/158477
>
I still don't see the value in doing this RX/TX queue pairing (unless
you're considering the possibility of explicitly binding sockets to
queue pairs).  XPS should be sufficient mechanism to get affinity on
sending side.  Also, don't know how the queue paring model will be
maintained when using priority queues on transmit-- transmit is likely
to be asymmetric to receive side.  The ability to seamlessly decouple
transmit queues and receive queues seems like a nice property.

>> Since the approach is based on Toeplitz it can be applied to all
>> hardware capable of generating a Toeplitz based hash and as a result=
 it
>> would likely also work in a much more vendor neutral kind of way tha=
n
>> Flow Director currently does.
>
The device hash should already be available in sk_rxhash, so maybe
that could be used for this purpose.  I think it is a good property to
keeping treat the device hashes as opaque values, any reasonable
32-bit 4-tuple hash should work equally well in the stack.
