From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 17:41:38 +0200
Message-ID: <516C1FB2.50900@onera.fr>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com> <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com> <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com> <516A8A60.5020003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:42921 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab3DOPqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 11:46:08 -0400
In-Reply-To: <516A8A60.5020003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/14/2013 12:52 PM, Daniel Borkmann wrote:
> Paul, since you've reported / requested this, your use case would be to
> fill
> the ring, trigger a sendto() and then loop through all the frames to
> check the
> tx timestamps for your custom protocol mockup, then fill the returned
> frames
> again, etc.?

I've run a test that create (and setup) a tx ring buffer with 8 frames, 
then fill the frames payload, then call sendto.
I've checked the timestamp by two means :
  - check the timestamp in the tx ring after the status became 
TP_STATUS_AVAILABLE again,
  - by issuing 8 recvmsg on the ERRQUEUE.
Both timestamp are coherents and increment themselves.

The tests has been done with a UML kernel, and with software timestamps.

 From my point of view, it seems usable.

However, I've found one strange behavior. I must call recvmsg as many 
times as i have submitted a frame, or not at all. If i only pop the 
ERRQUEUE for one or two message for instance, the next call to sentdo 
fails with "No message of desired type" (errno 42).


Paul.
