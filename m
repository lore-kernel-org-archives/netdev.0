From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 0/6] ipv4/fib_trie: Cleanups to prepare for introduction
 of key vector
Date: Wed, 04 Mar 2015 06:51:27 -0800
Message-ID: <54F71BEF.5030706@redhat.com>
References: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20> <20150304.001640.1653151786060996185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757733AbbCDOv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 09:51:29 -0500
In-Reply-To: <20150304.001640.1653151786060996185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/03/2015 09:16 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Mon, 02 Mar 2015 13:32:16 -0800
>
>> This patch series is meant to mostly just clean up the fib_trie to p=
repare
>> it for the introduction of the key_vector.  As such there are a numb=
er of
>> minor clean-ups such as reformatting the tnode to match the format o=
nce the
>> key vector is introduced, some optimizations to drop the need for a =
leaf
>> parent pointer, and some changes to remove duplication of effort suc=
h as
>> the 2 look-ups that were essentially being done per node insertion.
> This doesn't compile with trie stats enabled, I see something sneakin=
g
> in from the main/local table collapsing patch :-)
>
> net/ipv4/fib_trie.c: In function =91__trie_free_rcu=92:
> net/ipv4/fib_trie.c:1601:36: error: =91struct fib_table=92 has no mem=
ber named =91data=92
>    struct trie *t =3D (struct trie *)tb->data;

Ugh, sorry about that I will fix it this morning.

> Also, two comments:
>
> 1) When you go "if (idx >> n->bits)", can n->bits be =3D=3D 32?  If s=
o, this
>     expression is undefined.

If bits can be 32 then idx should be an unsigned long which is 64 bits.=
 =20
I will double check to make sure that is still the case.

The general idea is if a long is 32 bits then we likely cannot allocate=
=20
a 32 bit tnode since that would more than consume all of the available=20
memory in the system.  I can look into adding a comment to that effect=20
somewhere.

> 2) In your simplification of fib_find_node(), don't keep storing over
>     and over again into the on-stack variable '*tp', instead just mai=
ntain
>     a one behind pointer in a local variable for the parent, and stor=
e it
>     one time as your exit the function.
>
> Thanks.

Okay I will update it.  As I recall that is what the compiler ends up=20
doing anyway since fib_find_node ends up being inlined leaving the=20
parent as just a local variable.

- Alex
