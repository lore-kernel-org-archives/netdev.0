From: Josh Lehan <linux@krellan.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Sun, 05 Jun 2011 23:30:17 -0700
Message-ID: <4DEC73F9.2040907@krellan.com>
References: <4DE44218.4070306@krellan.com> <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com> <4DE5F3E3.2080609@krellan.com> <alpine.DEB.2.00.1106031428280.17529@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Lehan <linux@krellan.com>, netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server4.hostdango.com ([70.86.37.74]:50804 "EHLO
	server4.hostdango.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab1FFGaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 02:30:20 -0400
In-Reply-To: <alpine.DEB.2.00.1106031428280.17529@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2011 04:51 AM, Ilpo J=C3=A4rvinen wrote:
> And you'd send a cumulative ACK without the actual data segment...?=20
> ...That's gonna break many middleboxes which would want to see that=20
> data segment too ...And there goes your "viability" (though with luck=
 it=20
> will _sometimes_ work as rexmit of the data segment is already in fli=
ght).=20

No, there would be no wire-visible change.  This idea was explored at
first, and then rejected.  As you mentioned, this would break many
middleboxes.  It would rightfully be considered an "optimistic ACK atta=
ck".

The late data segment would have to eventually arrive.  It would either
be dropped, if the userspace application had already skipped beyond tha=
t
point, or better yet, it could be re-inserted into the data stream (if
too late for live playback, then it could at least be saved into the
rewind buffer, or saved to disk if the user is doing that).

> In addition, such a non-legimite cumulative ACK probably violates num=
ber=20
> of TCP RFCs or at least assumptions made in them... e.g., for starter=
s,=20
> please explain which timestamp you would be putting there into that=20
> particular cumulative ACK?

It wouldn't change anything on the wire.  As you mentioned, timestamps
remain a good defense for guarding against optimistic ACK attacks.

Josh Lehan
