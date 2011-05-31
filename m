From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Tue, 31 May 2011 10:23:44 -0700
Message-ID: <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
References: <4DE44218.4070306@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, jiyengar@fandm.edu
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:42045 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab1EaRYH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 13:24:07 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4VHO5YQ018920
	for <netdev@vger.kernel.org>; Tue, 31 May 2011 10:24:06 -0700
Received: from ywa8 (ywa8.prod.google.com [10.192.1.8])
	by kpbe17.cbf.corp.google.com with ESMTP id p4VHN5DY021087
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 31 May 2011 10:24:04 -0700
Received: by ywa8 with SMTP id 8so2785398ywa.23
        for <netdev@vger.kernel.org>; Tue, 31 May 2011 10:24:04 -0700 (PDT)
In-Reply-To: <4DE44218.4070306@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 30, 2011 at 6:19 PM, Josh Lehan <linux@krellan.com> wrote:
>
> Hello. =A0I looked, but could not find an answer. =A0Is there already=
 an
> ioctl() or something like that in Linux, that would allow a userspace
> TCP socket to skip past a lost packet?
>
> The kernel already will continue to queue up packets, and with TCP SA=
CK,
> the kernel can acknowledge reception of further packets beyond the lo=
st
> packet, allowing the queue to continue growing. =A0However, all these
> queued packets won't be delivered to userspace until the original los=
t
> packet is received again, after it has been retransmitted.
>
> Is there a way for a userspace program to prevent this needless stall=
?

This paper may have a solution to your problem
"Minion=97an All-Terrain Packet Packhorse to Jump-Start Stalled Interne=
t
Transports"
http://csweb1.fandm.edu/jiyengar/lair/papers/minion-pfldnet2010.pdf

> It would be great if there was an ioctl() or similar call, that would
> tell the kernel that it's OK to leave a gap in the data stream, and
> resume supplying userspace with more data. =A0An obvious application =
would
> be media streaming, and many high-level media protocols do their own
> block framing anyway, so resynchronization after the data gap would n=
ot
> be a problem.
>
> This sounds like something that would be a FAQ, and if so, please poi=
nt
> me to the answer. =A0Thank you!
>
> Josh Lehan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
