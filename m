From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Bug#577640: linux-image-2.6.33-2-amd64: Kernel warnings in netns
	thread
Date: Thu, 22 Apr 2010 16:05:13 +0200
Message-ID: <y2kb9800b71004220705s4db40c4csb3923b61f9ae8321@mail.gmail.com>
References: <20100413112017.8505.36380.reportbug@japot.localdomain>
	 <1271612005.3679.248.camel@localhost>
	 <o2jb9800b71004210819t6ca61099y17be143527ccbc95@mail.gmail.com>
	 <m1ljcgzjh4.fsf@fess.ebiederm.org> <1271895278.2582.3.camel@localhost>
	 <m1sk6oky96.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>, 577640@bugs.debian.org,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:65439 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab0DVOFP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 10:05:15 -0400
Received: by bwz25 with SMTP id 25so9680803bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 07:05:13 -0700 (PDT)
In-Reply-To: <m1sk6oky96.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 04:38, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
>>> > $ sudo ./startns bash
>>> > # ip l a type veth
>>> > # ip l s veth0 netns 1
>>> > # exit

> Then I should ask what is startns?

That's just a simple C program that calls unshare(CLONE_NEWNET) and
execs a shell.

> Either that is doing something different from my equivalent program, =
or I have
> patches to fix this, that just haven't been merged yet.

I have just downloaded and compiled 2.6.32-2 and 2.6.34-rc5 from
kernel.org using the .config from the debian package, and the oops is
reproducible in both.

This small C file reproduces the error every time:

$ cat netnsoops.c
#include <stdio.h>
#include <stdlib.h>
#define _GNU_SOURCE
#include <sched.h>

int main(int argc, char *argv[])
{=09
	int c;
	unsigned long flags =3D CLONE_NEWNET;

	if(unshare(flags) =3D=3D -1) {
		perror("unshare");
		return 1;
	}
	system("ip link add name FOO type veth peer name BAR");
	system("ip link set FOO netns 1");
	system("ip link show");
	return 0;
}


--=20
Mart=EDn Ferrari
