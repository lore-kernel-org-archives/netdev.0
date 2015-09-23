From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/9 v2] net: Refactor ip_route_input_slow
Date: Wed, 23 Sep 2015 08:15:13 -0700
Message-ID: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36579 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598AbbIWPPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:45 -0400
Received: by pacgz1 with SMTP id gz1so8978746pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_route_input_slow is a maze of gotos (9 of them!) making it error
prone and difficult to read. This patchset refactors it, removing all
but 2 of the labels. The brd_input label for broadcast path requires
too many inputs to make a reasonble helper out of it so I left it as is.

None of these patches change functionality, only move code around
to make ip_route_input_slow more readable.

Size comparison using gcc version 4.7.2 (Debian 4.7.2-5)

With CONFIG_IP_ROUTE_VERBOSE:
    Before patches:
    $ size kbuild2/net/ipv4/route.o
       text	   data	    bss	    dec	    hex	filename
      20615	   2321	     32	  22968	   59b8	kbuild2/net/ipv4/route.o

    After patches:
    $ size kbuild/net/ipv4/route.o
       text	   data	    bss	    dec	    hex	filename
      20711	   2321	     32	  23064	   5a18	kbuild/net/ipv4/route.o

An increase of 96 bytes with CONFIG_IP_ROUTE_VERBOSE.

Without CONFIG_IP_ROUTE_VERBOSE:
    Before patches:
    $ size kbuild2/net/ipv4/route.o
       text	   data	    bss	    dec	    hex	filename
      19778	   2321	     32	  22131	   5673	kbuild2/net/ipv4/route.o

    After patches:
    $ size kbuild/net/ipv4/route.o
       text	   data	    bss	    dec	    hex	filename
      19847	   2321	     32	  22200	   56b8	kbuild/net/ipv4/route.o

An increase of 69 bytes without CONFIG_IP_ROUTE_VERBOSE.

v2
- Addressed comments from Eric B and Alex Duyck

David Ahern (9):
  net: Remove martian_source_keep_err goto label
  net: Remove e_inval label from ip_route_input_slow
  net: Remove e_nobufs label from ip_route_input_slow
  net: Move rth handling from ip_route_input_slow to helper
  net: Move martian_destination to helper
  net: Remove martian_source goto
  net: Remove martian_destination label
  net: Remove local_input label
  net: Remove no_route label

 net/ipv4/route.c | 233 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 133 insertions(+), 100 deletions(-)

-- 
1.9.1
