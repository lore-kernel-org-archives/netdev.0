From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: patch to improve x.25 throughput negotiation
Date: Tue, 6 Apr 2010 22:09:10 +1000
Message-ID: <v2jd45a3acc1004060509u88f32fa1va0c374154806535b@mail.gmail.com>
References: <4BB8C2CA.6040102@Calva.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: John Hughes <john@calva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:55242 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab0DFMJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:09:12 -0400
Received: by pwj9 with SMTP id 9so1075343pwj.19
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 05:09:11 -0700 (PDT)
In-Reply-To: <4BB8C2CA.6040102@Calva.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have reproduced a few ways.
1. X25_MASK_THROUGHPUT on the x25_subscript_struct, then call
SIOCX25SSUBSCRIP, then call SIOCX25FACILITIES without setting the
throughput field. Call connect.
2. No subscrip setting, call SIOCX25FACILITIES without setting the
throughput field. Call connect.
3. No subcrip, no facilities ioctl, call connect.

The patch removes the bad facility and makes the router accept the
call for the above cases.
I don't currently have a setup to test both direction throughput negoti=
ation.

Tested-by: Andrew Hendry <andrew.hendry@gmail.com>

On Mon, Apr 5, 2010 at 2:48 AM, John Hughes <john@calva.com> wrote:
> The current X.25 code has some bugs in throughput negotiation:
>
> =A01. It does negotiation in all cases, usually there is no need
> =A02. It incorrectly attempts to negotiate the throughput class in on=
e
> =A0 =A0 direction only. =A0There are separate throughput classes for =
input
> =A0 =A0 and output and if either is negotiated both mist be negotiate=
s.
>
> This is bug https://bugzilla.kernel.org/show_bug.cgi?id=3D15681
>
> This bug was first reported by Daniel Ferenci to the linux-x25 mailin=
g list
> on 6/8/2004, but is still present.
>
>
