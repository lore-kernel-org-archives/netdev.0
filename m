From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 6/8] tools: bpftool: print all relevant byte
 opcodes for "load double word"
Date: Fri, 20 Oct 2017 18:12:39 +0200
Message-ID: <59EA2077.7000901@iogearbox.net>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com> <20171019224626.31608-7-jakub.kicinski@netronome.com> <063D6719AE5E284EB5DD2968C1650D6DD009D515@AcuExch.aculab.com> <CAH3iqT5vPnOCEm6wjavbpSyC4Md922Bts3ynxxVCT-1=MWsgKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Laight <David.Laight@aculab.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: Quentin Monnet <quentin.monnet@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42134 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751698AbdJTQMn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 12:12:43 -0400
In-Reply-To: <CAH3iqT5vPnOCEm6wjavbpSyC4Md922Bts3ynxxVCT-1=MWsgKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 05:50 PM, Quentin Monnet wrote:
[...]
> The remaining four bytes are taken from the "immediate" field of the second
> instruction, which leaves the first four fields (offset, source and destination
> registers, and in particular opcode) unused. As far as I know, these fields
> remain at zero, and this makes it the only “instruction” to have a null code
> (although I am not sure this is a strict requirement, because I did not find
> the code in the verifier that would reject a program having a non-null opcode
> right after a "load double word immediate" instruction).

It's in replace_map_fd_with_map_ptr(), invalid insns for the 2nd part
are rejected there, they have to be otherwise it's not extendable anymore
from abi pov; check also 'test1* ld_imm64' in the verifier test cases.

Cheers,
Daniel
