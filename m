From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map implementation
Date: Fri, 06 Jan 2017 11:43:21 +0100
Message-ID: <586F74C9.3020305@iogearbox.net>
References: <20161229172855.14910-1-daniel@zonque.org> <20161229172855.14910-2-daniel@zonque.org> <586E7366.1010708@iogearbox.net> <586EA627.6020404@iogearbox.net> <2edd2b2b-a89e-0df0-c1dc-fdaee2315597@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37249 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933277AbdAFKn1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 05:43:27 -0500
In-Reply-To: <2edd2b2b-a89e-0df0-c1dc-fdaee2315597@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2017 09:14 PM, Daniel Mack wrote:
[...]
> In my use case, the actual value of a node is in fact ignored, all that
> matters is whether a node exists in a trie or not. The test code uses
> u64 for its tests.
>
> I can change it around so that the value size can be defined by
> userspace, but ideally it would also support 0-byte lengths then. The
> bpf map syscall handler should handle the latter just fine if I read the
> code correctly?

Right now no map is allowed to have value size of 0, but since kmalloc()
would return ZERO_SIZE_PTR in such case, it looks like it should
work^tm, although I haven't checked whether it's guaranteed that all
the copy_{from,to}_user() implementations work with 0 size as well
and whether ubsan would complain on the ZERO_SIZE_PTR for memcpy() etc.
Perhaps better to reject value size of 0 initially and later on follow
up with making the syscall code more robust for such cases (afaik, for
the htab this was also on todo.)?

Thanks,
Daniel
