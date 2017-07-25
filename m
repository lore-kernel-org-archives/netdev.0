From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2] bpf: install libbpf headers on 'make install'
Date: Tue, 25 Jul 2017 21:45:28 +0200
Message-ID: <59779FD8.7070107@iogearbox.net>
References: <20170724212236.21903-1-jakub.kicinski@netronome.com> <20170725181711.21236-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        acme@redhat.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34644 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750857AbdGYTpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 15:45:31 -0400
In-Reply-To: <20170725181711.21236-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2017 08:17 PM, Jakub Kicinski wrote:
> Add a new target to install the bpf.h header to $(prefix)/include/bpf/
> directory.  This is necessary to build standalone applications using
> libbpf, without the need to clone the kernel sources and point to them.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Looks good to me, we might do the same for libbpf.h later on as
well, though the naming scheme is a confusing choice (bpf.h and
libbpf.h).

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> ---
> v2:
>   - make the header installation similar to tools/lib/traceevent (Daniel).
>
> The functional change is that the header will not be installed as part
> of make install, one has to make install_headers, which seems OK.
>
> Out of curiosity - why are only "force elfdep bpfdep" added to the PHONY
> target?  Is there some Makefile magic that makes adding install* targets
> there unnecessary?  Or does the PHONY target just not matter in practice
> so it's not updated?

Arnaldo might know better.

>   tools/lib/bpf/Makefile | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
> index 1f5300e56b44..445289555487 100644
> --- a/tools/lib/bpf/Makefile
> +++ b/tools/lib/bpf/Makefile
> @@ -189,6 +189,10 @@ install_lib: all_cmd
>   	$(call QUIET_INSTALL, $(LIB_FILE)) \
>   		$(call do_install,$(LIB_FILE),$(libdir_SQ))
>
> +install_headers:
> +	$(call QUIET_INSTALL, headers) \
> +		$(call do_install,bpf.h,$(prefix)/include/bpf,644)
> +
>   install: install_lib
>
>   ### Cleaning rules
>
