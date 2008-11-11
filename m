From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 10:14:54 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:51160 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbYKKSO4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 13:14:56 -0500
In-Reply-To: <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-11-08 9:50 AM
> To: Lovich, Vitali
> Cc: Evgeniy Polyakov; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Vitali,
> 
> You say "There is only 1 destructor for the layer that created the skb
> (AFAIK)", why not a "There is only 1 destructor argument for the layer
> that created the skb (AFAIK)"?
> Where is the impact? only a void * destructor_arg that only the
> creator of skb is allowed to use. Moreover it can be put under feature
> flag.
Right, we're saying the exact same thing I think.  I had wanted just a void * that is specific to PACKET_MMAP, so that no one else pays the price if they don't need to.  You instead want to make it a feature flag - that's fine I think, but we need to make a note of that in the Kconfig file (that enabling PACKET_MMAP increases all skbs by the size of a long).  I'd still rather prefer using the fragments instead though, because it seems like a reasonable solution that has 0 impact on any other code.

> 
> >>
> >> This can be used also for sock_w_free() destructor. Current code is
> >> assuming that the socket destructor is always sock_w_free(), if
> >> tomorrow, this callback is changed or removed, we will have to
> change
> >> packet_mmap code (called in packet_skb_destruct()). Such mechanism
> >> should make replacement of destructor/destructor arg more
> independent
> >> toward layers.
> > We're talking about skb destructors, not socket destructors.
> sock_wfree is not a destructor - it releases the resources allocated to
> the skb back to the socket that the resources are from.
> I agree, I'm just talking about destructor/destructor_arg pair.
> 
> >
> > Also, from what I can tell, this is how the Linux kernel works - if
> someone's change breaks the code, they're responsible for fixing it.
> Changing how sock_wfree is fairly significant enough that we don't need
> to worry about making it easier - it'll probably be so significant that
> there will be a lot of changes anyways.  It's also highly unlikely to
> happen I think.
> 
> I don't want to break this code. Just add a variable in sk_buff that
> can be used as the destructor is ! kind of CB[] that is not
> overwritten by sub layer ! or at least backuped.	
I wasn't implying you will break the code.  I was implying that if someone was changing how sock_wfree was used they would be breaking the code.  We don't need to make it easier for them.  Again, I'm not really convinced of the utility of such a feature when it seems like this is the only code that would benefit, and even then there's a way around it.

Vitali
