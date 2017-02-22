From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Wed, 22 Feb 2017 23:29:56 +0200
Message-ID: <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com> <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        pablo <pablo@netfilter.org>, laforge <laforge@gnumonks.org>,
        netdev <netdev@vger.kernel.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36268 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933981AbdBVV36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 16:29:58 -0500
Received: by mail-oi0-f53.google.com with SMTP id s205so8458872oif.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 13:29:57 -0800 (PST)
In-Reply-To: <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 11:58 PM, Andreas Schultz <aschultz@tpip.net> wrote:
> Hi Or,
> ----- On Feb 16, 2017, at 3:59 PM, Or Gerlitz ogerlitz@mellanox.com wrote:
>
>> Generate the source udp header according to the flow represented by
>> the packet we are encapsulating, as done for other udp tunnels. This
>> helps on the receiver side to apply RSS spreading.
>
> This might work for GTPv0-U, However, for GTPv1-U this could interfere
> with error handling in the user space control process when the UDP port
> extension  header is used in error indications.


in the document you posted there's this quote "The source IP and port
have no meaning and can change at any time" -- I assume it refers to
v0? can we identify in the kernel code that we're on v0 and have the
patch come into play?

> 3GPP TS 29.281 Rel 13, section 5.2.2.1 defines the UDP port extension and
> section 7.3.1 says that the UDP source port extension can be used to
> mitigate DOS attacks. This would IMHO imply that the user space control
> process needs to know the TEID to UDP source port mapping.

> The other question is, on what is this actually hashing. When I understand
> the code correctly, this will hash on the source/destination of the orignal
> flow. I would expect that a SGSN/SGW/eNodeB would like the keep flow
> processing on a per TEID base, so the port hashing should be base on the TEID.

is it possible for packets belonging to the same TCP session or UDP
"pseudo session" (given pair of src/dst ip/port) to be encapsulated
using different TEID?

hashing on the TEID imposes a harder requirement on the NIC HW vs.
just UDP based RSS.
