From: kuznet@ms2.inr.ac.ru
Subject: Re: off by one error in 3des cbc keying
Date: Tue, 12 Nov 2002 18:29:06 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211121529.SAA00584@sex.inr.ac.ru>
References: <20021112151638.GA18488@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20021112151638.GA18488@outpost.ds9a.nl> from "bert hubert" at Nov 12, 2 04:16:38 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > The problem with expiration remains unsolved. I still cannot reproduce this
> > and cannot find a situation when kernel can create two larvals with one
> > identity. :-( Searching.
> 
> Sure you saw that? I only saw the one larval in the output I sent you,

Sure, unless my sick cisco router corrupts mails. But I hope it is not
so malicious. :-)

Joke aparts, of course, I did not see this, it exists for short time,
you see one of them already grown to mature.

10.0.0.216 10.0.0.11 
	esp mode=transport spi=57115683(0x03678423) reqid=0(0x00000000)
	E: 3des-cbc  cc8e8e4f 91d41b7b ea6cbb3c 24a465cb a08b33aa c8ec1274
	A: hmac-sha1  f454ab03 3a803ca4 05239de3 100ce68f d283f10a
	seq=0x00000000 replay=4 flags=0x00000000 state=mature 
	created: Nov 11 22:42:38 2002	current: Nov 11 22:43:05 2002
	diff: 27(s)	hard: 600(s)	soft: 480(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=2 pid=8126 refcnt=0
10.0.0.216 10.0.0.11 
	esp mode=transport spi=0(0x00000000) reqid=0(0x00000000)
	seq=0x00000000 replay=0 flags=0x00000000 state=larval 
	created: Nov 11 22:42:37 2002	current: Nov 11 22:43:05 2002
	diff: 28(s)	hard: 30(s)	soft: 0(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=1 pid=8126 refcnt=0

This MUST NOT happen. The first one was larval while for a second
before line:

22:42:38: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.11->10.0.0.216 spi=222275495(0xd3fa7a7)

Essentially, seeing this you see a bug in kernel.

Alexey
