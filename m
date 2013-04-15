From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 18:56:03 +0200
Message-ID: <20130415165603.GD2534@netboy>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com>
 <5169D9C8.8010504@redhat.com>
 <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com>
 <516A8A60.5020003@redhat.com>
 <20130414130726.GB2871@netboy>
 <516BAE3A.5020508@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51035 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab3DOQ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 12:56:16 -0400
Received: by mail-ee0-f46.google.com with SMTP id d49so2312025eek.19
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:56:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <516BAE3A.5020508@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 09:37:30AM +0200, Paul Chavent wrote:
> On 04/14/2013 03:07 PM, Richard Cochran wrote:
> >As it stand now, it is fairly useless, since there is no way for user
> >space to tell which kind of time stamp has been reported. In fact, the
> >code will silently intermingle hardware and software time stamps. That
> >is surely a mean trick to play on the users.
> 
> Isn't it the one that the user ask with setsockopt(fd, SOL_PACKET,
> PACKET_TIMESTAMP, &timestamping, sizeof(timestamping)) ?

No, not necessarily. Look at the code in net/packet/af_packet.c.

		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
				&& shhwtstamps->syststamp.tv64)
			ts = ktime_to_timespec(shhwtstamps->syststamp);
		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
				&& shhwtstamps->hwtstamp.tv64)
			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
		else if (skb->tstamp.tv64)
			ts = ktime_to_timespec(skb->tstamp);
		else
			getnstimeofday(&ts);

What happens if RAW is requested, but no HW time stamp is available?

 
> However, i wonder why you added an other sockopt that do the same
> thing as SOL_SOCKET/SO_TIMESTAMPING sockopt ?

Not sure what you mean. I did not add the SOL_PACKET socket option.

Thanks,
Richard
