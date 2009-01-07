From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 14:47:03 +0300
Message-ID: <20090107114703.GB28161@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:33000 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751073AbZAGLrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 06:47:06 -0500
Content-Disposition: inline
In-Reply-To: <1231307334-9542-2-git-send-email-michael@laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael.

On Wed, Jan 07, 2009 at 12:48:54AM -0500, Michael Stone (michael@laptop.org) wrote:
> Daniel Bernstein has observed [1] that security-conscious userland processes
> may benefit from the ability to irrevocably remove their ability to create,
> bind, connect to, or send messages except in the case of previously connected
> sockets or AF_UNIX filesystem sockets. We provide this facility by implementing
> support for a new rlimit called RLIMIT_NETWORK.
> 
> This facility is particularly attractive to security platforms like OLPC
> Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4].
> 
> [1]: http://cr.yp.to/unix/disablenetwork.html
> [2]: http://wiki.laptop.org/go/OLPC_Bitfrost
> [3]: http://wiki.laptop.org/go/Rainbow
> [4]: http://plash.beasts.org/
> ---
>  Documentation/rlimit_network.txt |   48 ++++++++++++++++++++++++++++++++
>  fs/proc/base.c                   |    1 +
>  include/asm-generic/resource.h   |    4 ++-
>  net/socket.c                     |   57 +++++++++++++++++++++++++++++--------
>  net/unix/af_unix.c               |   28 ++++++++++++++++++
>  5 files changed, 124 insertions(+), 14 deletions(-)
>  create mode 100644 Documentation/rlimit_network.txt
> 
> diff --git a/Documentation/rlimit_network.txt b/Documentation/rlimit_network.txt
> new file mode 100644
> index 0000000..e7cc3e4
> --- /dev/null
> +++ b/Documentation/rlimit_network.txt
> @@ -0,0 +1,48 @@
> +Purpose
> +-------
> +
> +Daniel Bernstein has observed [1] that security-conscious userland processes
> +may benefit from the ability to irrevocably remove their ability to create,
> +bind, connect to, or send messages except in the case of previously connected
> +sockets or AF_UNIX filesystem sockets.
> +
> +This facility is particularly attractive to security platforms like OLPC
> +Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4] because:
> +
> +  * it integrates well with standard techniques for writing privilege-separated
> +    Unix programs
> +
> +  * it's available to unprivileged programs
> +

It isn't, since it can not set rlimit, and if it can, it still can drop
it.

Your code does not cover sendpage() interface (aka splice() and
sendfile()) and with your approach application will suddenly stops
sending data even into old sockets, but will be able to receive it from
anywhere. Is it intentional?

The same goal can be achieved with 'owner' iptables match module btw.

-- 
	Evgeniy Polyakov
