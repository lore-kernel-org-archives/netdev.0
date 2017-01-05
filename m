From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map
 implementation
Date: Thu, 5 Jan 2017 21:14:42 +0100
Message-ID: <2edd2b2b-a89e-0df0-c1dc-fdaee2315597@zonque.org>
References: <20161229172855.14910-1-daniel@zonque.org>
 <20161229172855.14910-2-daniel@zonque.org> <586E7366.1010708@iogearbox.net>
 <586EA627.6020404@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Borkmann <daniel@iogearbox.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34990 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033332AbdAEUOp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 15:14:45 -0500
In-Reply-To: <586EA627.6020404@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 01/05/2017 09:01 PM, Daniel Borkmann wrote:
> On 01/05/2017 05:25 PM, Daniel Borkmann wrote:
>> On 12/29/2016 06:28 PM, Daniel Mack wrote:

> [...]
>>> +static struct bpf_map *trie_alloc(union bpf_attr *attr)
>>> +{
>>> +    struct lpm_trie *trie;
>>> +
>>> +    /* check sanity of attributes */
>>> +    if (attr->max_entries == 0 || attr->map_flags ||
>>> +        attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
>>> +        attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
>>> +        attr->value_size != sizeof(u64))
>>> +        return ERR_PTR(-EINVAL);
> 
> One more question on this regarding value size as u64 (perhaps I
> missed it along the way): reason this was chosen was because for
> keeping stats? Why not making user choose a size as in other maps,
> so also custom structs could be stored there?

In my use case, the actual value of a node is in fact ignored, all that
matters is whether a node exists in a trie or not. The test code uses
u64 for its tests.

I can change it around so that the value size can be defined by
userspace, but ideally it would also support 0-byte lengths then. The
bpf map syscall handler should handle the latter just fine if I read the
code correctly?


Thanks,
Daniel
