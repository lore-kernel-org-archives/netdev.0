From: "Oliver Hartkopp" <oliver@hartkopp.net>
Subject: dropwatch for network drop monitor
Date: Fri, 17 Apr 2009 14:57:24 +0200 (MEST)
Message-ID: <200904171257.n3HCvOba029938@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from em-p00-ob.rzone.de ([81.169.146.225]:32550 "EHLO
	em-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbZDQM7S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 08:59:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal,

i tried the dropwatch app from your git.

Compiling the source produces:

hartko@vwagwolkf320:~/dropwatch/src$ make
gcc -c -g main.c
gcc -c -g lookup.c
gcc -c -g lookup_bfd.c
gcc -c -g lookup_kas.c
lookup_kas.c: In function =91lookup_kas_cache=92:
lookup_kas.c:56: warning: cast from pointer to integer of different siz=
e
lookup_kas.c: In function =91lookup_kas_proc=92:
lookup_kas.c:100: warning: cast from pointer to integer of different si=
ze
lookup_kas.c:103: warning: cast from pointer to integer of different si=
ze
gcc -g -o dropwatch main.o lookup.o lookup_bfd.o lookup_kas.o -lbfd -lr=
eadline -lnl=20

You cast a 'pc' variable to __u64 - is your code depending on 64 bit ??

Starting the stuff brings:

vwagwolkf320:/home/hartko/dropwatch/src# ./dropwatch=20
Initalizing kallsyms db
dropwatch> start
Enabling monitoring...
Waiting for activation ack....
Waiting for activation ack....
Waiting for activation ack....
Waiting for activation ack....
Waiting for activation ack....
Waiting for activation ack....
=46ailed activation request, error: Operation now in progress
Shutting down ...
vwagwolkf320:/home/hartko/dropwatch/src#=20

And in my kernel log i get at the same time:
[ 7070.568482] netlink: 60 bytes leftover after parsing attributes.

Any ideas?

Oliver

