From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 14:43:07 +0100
Message-ID: <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
References: <20081106194032.GB31673@ioremap.net>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
	 <20081111185036.GA17717@ioremap.net>
	 <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
	 <20081111192954.GA19409@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:30633 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbYKLNnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 08:43:09 -0500
Received: by fk-out-0910.google.com with SMTP id 18so443965fkq.5
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 05:43:07 -0800 (PST)
In-Reply-To: <20081111192954.GA19409@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> There are several possibilities:
> * update destructor with your own data and put old one behind the data
>        in skb
> * update destructor, but put your own data into some storage which can
>        be accessed from your callback, storage entry may contain
>        whatever data you want and of course old destructor
> * put your data into socket pointer (there still may be issues with
>        destructor)
> * if you fully own the skb, reuse whatever members there you like
>        (except those which may be used by lower layer)
> * find why do you need to have callback at destruction time and
>        eliminate this problem.
>        Btw, netchannels do this way, since they are very similar to
>        packet socket, but compared to your approach they have a copy.
>
Thanks a lot for this list :)
So for example, is using of skb->mark to store a buffer index a good solution ?
Or do you prefer another solution?

> At the first place I do not understand, why do you want to change the
> skb, since you can mmap whatever area you need and provide those pages
> into skb, which at free time will drop the reference counter. Skb lives
> in socket queue, so until it is empty you can sleep not allowing mapped
> buffer to shrink.
We need to get the tpacket_hdr associated to data in skb in order to
inform user that buffer is now available (This is done through status
field, which is not sent over the network). What do you mean with
"provide those pages", through frags? If yes, is it ok when frags are
linearized?

Best regards,
Johann


-- 
Johann Baudy
johaahn@gmail.com
