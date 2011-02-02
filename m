From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: af_unix unix_getname: return size for unnamed sockets too small?
Date: Wed, 02 Feb 2011 10:59:30 -0800
Message-ID: <m139o6qn3h.fsf@fess.ebiederm.org>
References: <20110202174015.GB25515@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gorcunov@openvz.org
To: Marcus Meissner <meissner@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57922 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab1BBS7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 13:59:38 -0500
In-Reply-To: <20110202174015.GB25515@suse.de> (Marcus Meissner's message of
	"Wed, 2 Feb 2011 18:40:15 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcus Meissner <meissner@suse.de> writes:

> Hi,
>
> In net/unix/af_unix.c::unix_getname() there is a small problem:
>
>         if (!u->addr) {
>                 sunaddr->sun_family = AF_UNIX;
>                 sunaddr->sun_path[0] = 0;		// not copied out
>                 *uaddr_len = sizeof(short);
>         } else {
>                 struct unix_address *addr = u->addr;
>
>                 *uaddr_len = addr->len;
>                 memcpy(sunaddr, addr->name, *uaddr_len);
>         }
>
> The if (!u->addr) case will not copy out the \0 in the sun_path, as
> uaddr_len is just the size of sun_family.
>
> (Shown by socat crashing after decoding gethostname return and expected
> sun_path to be a valid string (and not seeing the \0)).

Perhaps my memory is scrambled but the sun_path has embedded '\0's so I
don't see how a correct application can expect the path to be '\0'
terminated.  An application should be looking at the length we give it.

> Should it perhaps be *uaddr_len = sizeof(short)+sizeof(char)?

I don't think so.

Eric

