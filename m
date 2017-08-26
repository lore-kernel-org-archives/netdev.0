From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] selftests/bpf: check the instruction dumps are
 populated
Date: Sat, 26 Aug 2017 03:16:06 +0200
Message-ID: <59A0CBD6.6000602@iogearbox.net>
References: <20170825213957.4768-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35754 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751407AbdHZBQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 21:16:11 -0400
In-Reply-To: <20170825213957.4768-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2017 11:39 PM, Jakub Kicinski wrote:
> Add a basic test for checking whether kernel is populating
> the jited and xlated BPF images.  It was used to confirm
> the behaviour change from commit d777b2ddbecf ("bpf: don't
> zero out the info struct in bpf_obj_get_info_by_fd()"),
> which made bpf_obj_get_info_by_fd() usable for retrieving
> the image dumps.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
[...]
> @@ -328,15 +331,20 @@ static void test_bpf_obj_id(void)
>   			  prog_infos[i].type != BPF_PROG_TYPE_SOCKET_FILTER ||
>   			  info_len != sizeof(struct bpf_prog_info) ||
>   			  (jit_enabled && !prog_infos[i].jited_prog_len) ||
> -			  !prog_infos[i].xlated_prog_len,
> +			  (jit_enabled &&
> +			   !memcmp(jited_insns, zeros, sizeof(zeros))) ||
> +			  !prog_infos[i].xlated_prog_len ||
> +			  !memcmp(xlated_insns, zeros, sizeof(zeros)),

There could still be the case where a JIT could bail out
for some reason and punt to the interpreter instead, but
I'm fine assuming for the specific test cases we have it
has to succeed, and if not JIT misses features or has other
issues. ;) Thus:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!
