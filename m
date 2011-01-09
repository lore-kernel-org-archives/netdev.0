From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Sun, 9 Jan 2011 23:33:19 +0100
Message-ID: <201101092333.19406.christoph.paasch@uclouvain.be>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be> <201101092232.19171.christoph.paasch@uclouvain.be> <1294610141.2823.31.camel@localhost>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294610141.2823.31.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday, January 09, 2011 wrote Ben Hutchings:
> The cost of repeated inclusion is minimal.  GCC's preprocessor
> recognises when the entire content of a file is conditional on #ifnde=
f
> FOO and will not even open it again if FOO is defined.
Thanks, I did not knew about that.

> If a file directly references definitions that are supposed to be
> provided by a certain header, changing it to rely on indirect inclusi=
on
> of that header generally does *not* aid maintenance.
But then, to be coherent, we would need to add the following includes (=
and I'm=20
even not 100% sure if it's all we need):

linux/percpu_counter.h (needed for percpu_counter_sum_positive)
linux/mm_types.h (needed for struct page)
linux/aio.h (needed for struct kiocb)
net/inet_sock.h (needed for struct ip_options)
linux/pipe_fs_i.h (needed for struct pipe_inode_info)
linux/poll.h (needed for struct poll_table_struct)
linux/compiler.h (needed for __percpu)

IMO there should be a clear rule for the inclusion of files.

Personally I think it's best to include as few files as possible. Becau=
se I=20
think, that this reduces the risk of including a file, whose structs/fu=
nctions=20
aren't even referenced (it's easier to manually check if one include ou=
t of 10=20
is useless, than checking it for 50).

But ok, there may be other stronger reasons for the opposite.
What are the reasons for including these files?

Regards,
Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=C3=A9 Catholique de Louvain

www.rollerbulls.be
--
