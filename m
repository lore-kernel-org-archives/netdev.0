From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Thu, 01 Jan 2015 16:25:38 +0100
Message-ID: <54A566F2.4070401@redhat.com>
References: <54A470B3.3010501@sec.in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Christian Grothoff <christian@grothoff.org>,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Julian Kirsch <kirschju@sec.in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbbAAP1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jan 2015 10:27:06 -0500
In-Reply-To: <54A470B3.3010501@sec.in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

On 12/31/2014 10:54 PM, Julian Kirsch wrote:
...
> one year ago [0] we tried to convince you to add support for a new
> socket option to the linux kernel. Equipped with an improved version of
> our patch we're back to accomplish this task today. :-)
>
> TCP Stealth is a modern variant of port knocking which borrows
> techniques from network steganography to enable clients to authenticate
> themselves towards a server on TCP level. You can find technical details
> in an rfc draft we wrote earlier this year [1] and in my master's thesis
> [2]. In summary, TCP Stealth derives authentication information from a
> pre-shared secret and embeds it into the ISN sent along with the first
> SYN from the client.

/me wondering (haven't tried that though) ... have you considered f.e.
building a library using a raw packet socket with a BPF filter to capture
SYN packets and then TCP_REPAIR [1] to build a full-blown TCP socket out
of it in case of a correct authentication from the ISN?

Thanks,
Daniel

   [1] http://www.criu.org/TCP_connection

> Our motivation is simple: During this year we gained hard evidence on
> secret services actively port scanning the internets followed by
> exploitation of your services using 0-day exploits [3, 4]. We don't want
> our machines to be turned into relays from where they continue to
> cascade their attacks. TCP Stealth makes port scanning more expensive by
> a factor of 2^31 (on average).
>
> A copy of this patch as well as patches for several user space
> applications can be found on the project's home page [5].
>
> All the best for the upcoming year,
> Julian & Christian
>
>
>
> [0] https://lkml.org/lkml/2013/12/10/1155
> [1] https://datatracker.ietf.org/doc/draft-kirsch-ietf-tcp-stealth/
> [2] https://gnunet.org/kirsch2014knock
> [3]
> http://www.heise.de/ct/artikel/NSA-GCHQ-The-HACIENDA-Program-for-Internet-Colonization-2292681.html
> [4]
> https://firstlook.org/theintercept/2014/12/13/belgacom-hack-gchq-inside-story/
> [5] https://gnunet.org/knock
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1
>
> iQEcBAEBAgAGBQJUpHCvAAoJENwkOWttRRA4g10IALbJZU9/5Gp8tVdpXqbkOIMp
> Kz+yOMyYULqYeM8yguSBZjZLbaz/VAS7SNpQxKGU+W0aAXa22FsSfVoUU7wqp3NT
> 3EGRuPkMaJkQ66IP8MtX+6/hSeWSh78tEaIFWVjyutihPyQGz0LefFc66gm54X4T
> s8IYW7jKFhNmmROu9CXLTxq4B5t2v+Evv/qWqotZqR1t3IbIUmZAiKrlkMRd7dtM
> SaS5JwFeiObxn+0M/7javQCAhfgPXYEOU0QKAGY55MXcPAner/5PuExIZdOJ41R3
> XD9tgoLGhHEiQkxj0/bP2cs3Cl5xfJl9t2iecVfTIR7PytaTJ/kFuE4gNgWEcTA=
> =T6/C
> -----END PGP SIGNATURE-----
>
