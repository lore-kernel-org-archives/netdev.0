From: Eugene Teo <eugeneteo@kernel.sg>
Subject: Re: [Security] inet_diag insufficient validation?
Date: Fri, 3 Jun 2011 14:55:44 +0800
Message-ID: <BANLkTin9fqYSxq4ne5hV_ri-zKeMZ9mE_g@mail.gmail.com>
References: <1306942849.3150.10.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	security@kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:46285 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256Ab1FCGzp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 02:55:45 -0400
Received: by pxi2 with SMTP id 2so1032488pxi.10
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 23:55:44 -0700 (PDT)
In-Reply-To: <1306942849.3150.10.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ed acme.

On Wed, Jun 1, 2011 at 11:40 PM, Dan Rosenberg <drosenberg@vsecurity.co=
m> wrote:
> It seems to me that the auditing performed by inet_diag_bc_audit() is
> insufficient to prevent pathological INET_DIAG bytecode from doing ba=
d
> things.
>
> Firstly, it's possible to cause an infinite loop in inet_diag_bc_audi=
t()
> with a INET_DIAG_BC_JMP opcode with a "yes" value of 0. =A0The valid_=
cc()
> function, also called from here, seems suspicious as well.
>
> Once the bytecode is actually run in inet_diag_bc_run(), it looks lik=
e
> more infinite loops are possible, if appropriate "yes" or "no" values
> are set to zero and weren't validated by the audit.
>
> Finally, I can't seem to find any validation that the reported length=
 of
> the netlink message header doesn't exceed the skb length, as checked =
in
> some other netlink receive functions, which could result in reading
> beyond the bounds of the socket data. =A0I could just be missing some=
thing
> here though.
>
> Regards,
> Dan
>
> _______________________________________________
> Security mailing list
> Security@linux.kernel.org
> http://linux.kernel.org/mailman/listinfo/security
>
