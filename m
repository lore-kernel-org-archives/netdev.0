From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Wed, 17 Apr 2013 12:22:18 +0200
Message-ID: <20130417102218.GA13873@netboy>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com>
 <5169D9C8.8010504@redhat.com>
 <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com>
 <516A8A60.5020003@redhat.com>
 <20130414130726.GB2871@netboy>
 <516BAE3A.5020508@onera.fr>
 <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Chavent <Paul.Chavent@onera.fr>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:55178 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758242Ab3DQKWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 06:22:30 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so643580eaj.8
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 03:22:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 12:59:26PM -0400, Willem de Bruijn wrote:
> 
> If I understand correctly, the problem that Richard refers to is that
> when one socket requests rx timestamping, all rx skbuffs have to be
> timestamped as it is not known early in the datapath to which socket
> they will be enqueued. As a result, the timestamps in skbuffs depend
> on the preferences of other active sockets. Correct me if I'm wrong.

No, that is not it.

Hardware time stamping needs to be globally enabled at the driver
level using the SIOCSHWTSTAMP [1] ioctl. The hardware has various
different abilities, usually one of:

- no time stamping
- some subset of PTP packets
- all packets

So depending on the mode, not all packets will receive a time
stamp. In addition, some of the hardware can only time stamp one
packet at a time. Furthermore, time stamps can get dropped in high
traffic situations.

The code in af_packet.c unconditionally delivers some sort of time
stamp, with an inexplicable fall back to gettimeofday. Thus, the user
space has no way of knowing what is being reported in the time stamp.

Thanks,
Richard

1. See Documentation/networking/timestamping.txt
