From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: simplify verifier register state assignments
Date: Thu, 07 Apr 2016 09:39:58 +0200
Message-ID: <57060ECE.9020300@iogearbox.net>
References: <1459996761-2926623-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60420 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbcDGHkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 03:40:05 -0400
In-Reply-To: <1459996761-2926623-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2016 04:39 AM, Alexei Starovoitov wrote:
> verifier is using the following structure to track the state of registers:
> struct reg_state {
>      enum bpf_reg_type type;
>      union {
>          int imm;
>          struct bpf_map *map_ptr;
>      };
> };
> and later on in states_equal() does memcmp(&old->regs[i], &cur->regs[i],..)
> to find equivalent states.
> Throughout the code of verifier there are assignements to 'imm' and 'map_ptr'
> fields and it's not obvious that most of the assignments into 'imm' don't
> need to clear extra 4 bytes (like mark_reg_unknown_value() does) to make sure
> that memcmp doesn't go over junk left from 'map_ptr' assignment.
>
> Simplify the code by converting 'int' into 'long'
>
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
