From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: install libbpf headers on 'make install'
Date: Tue, 25 Jul 2017 18:51:20 +0200
Message-ID: <59777708.7000707@iogearbox.net>
References: <20170724212236.21903-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60733 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdGYQvW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 12:51:22 -0400
In-Reply-To: <20170724212236.21903-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 11:22 PM, Jakub Kicinski wrote:
> Install the bpf.h header to $(prefix)/include/bpf/ directory.
> This is necessary to build standalone applications using libbpf,
> without the need to clone the kernel sources and point to them.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> I'm not 100% sure if it's OK to export the header file and which
> directory it should end up in (bpf/? libbpf/?).

Given the Makefile is heavily derived from tools/lib/traceevent/,
we should probably have a similar install_headers target instead,
in order to keep semantics similar. /include/bpf/ should be good.

>   tools/lib/bpf/Makefile | 9 ++++++++-
>   1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
> index 1f5300e56b44..22dad416e0bd 100644
> --- a/tools/lib/bpf/Makefile
> +++ b/tools/lib/bpf/Makefile
> @@ -46,6 +46,7 @@ else
>   endif
>
>   prefix ?= /usr/local
> +headerdir = $(prefix)/include/bpf/
>   libdir = $(prefix)/$(libdir_relative)
>   man_dir = $(prefix)/share/man
>   man_dir_SQ = '$(subst ','\'',$(man_dir))'
> @@ -90,11 +91,13 @@ endif
>   export prefix libdir src obj
>
>   # Shell quotes
> +headerdir_SQ = $(subst ','\'',$(headerdir))
>   libdir_SQ = $(subst ','\'',$(libdir))
>   libdir_relative_SQ = $(subst ','\'',$(libdir_relative))
>   plugin_dir_SQ = $(subst ','\'',$(plugin_dir))
>
>   LIB_FILE = libbpf.a libbpf.so
> +HEADER_FILE = bpf.h
>
>   VERSION		= $(BPF_VERSION)
>   PATCHLEVEL	= $(BPF_PATCHLEVEL)
> @@ -189,7 +192,11 @@ install_lib: all_cmd
>   	$(call QUIET_INSTALL, $(LIB_FILE)) \
>   		$(call do_install,$(LIB_FILE),$(libdir_SQ))
>
> -install: install_lib
> +install_hdr: all_cmd
> +	$(call QUIET_INSTALL, $(HEADER_FILE)) \
> +		$(call do_install,$(HEADER_FILE),$(headerdir_SQ))
> +
> +install: install_lib install_hdr
>
>   ### Cleaning rules
>
>
