From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 2.6.25 0/9]: SCTP: Update ADD-IP implementation to conform
 to spec
Date: Wed, 19 Dec 2007 15:53:47 -0500
Message-ID: <476984DB.4020403@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:8437 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbXLSUyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 15:54:35 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Vlad Yasevich wrote:
> The following is a set of patches that updates the SCTP ADD-IP implementation
> to conform to the recently published RFC.
> 
> ADD-IP is a SCTP Dynamic Address Configuration extensions, whereby
> the two end systems can dynamically modify the address lists for a given
> connection.  One of the applications of this is mobility.  The systems
> exchange Address Configuration (ASCONF) and Address Configuration
> Acknowlegement (ASCONF-ACK) messages which contain the info.  If you
> want more info the operation, read RFC 5061.
> 
> The implementation in lksctp was a few years old and implemented draft-05
> of the specification.  So this long overdue.
> 
> -vlad
> 

Not sure if you got the PATCH 7/9 resend, but it looks like netdev ate that
too.

I made this patch set available here:
 master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git addip

Vlad Yasevich (9):
      SCTP: Discard unauthenticated ASCONF and ASCONF ACK chunks
      SCTP: Handle the wildcard ADD-IP Address parameter
      SCTP: Add the handling of "Set Primary IP Address" parameter to INIT
      SCTP: Update association lookup to look at ASCONF chunks as well
      SCTP: ADD-IP updates the states where ASCONFs can be sent
      SCTP: Update ASCONF processing to conform to spec.
      SCTP: Change use_as_src into a full address state
      SCTP: Implement ADD-IP special case processing for ABORT chunk
      SCTP: Follow Add-IP security consideratiosn wrt INIT/INIT-ACK

 include/net/sctp/structs.h |   39 ++++++++----
 net/sctp/associola.c       |   75 +++++++++++++++++++++++-
 net/sctp/bind_addr.c       |   35 ++++++++++-
 net/sctp/input.c           |  124 ++++++++++++++++++++++++++++++++-------
 net/sctp/ipv6.c            |    2 +-
 net/sctp/outqueue.c        |   29 ++++++++-
 net/sctp/protocol.c        |    8 +-
 net/sctp/sm_make_chunk.c   |  132 +++++++++++++++++++++++++++++++++++------
 net/sctp/sm_statefuns.c    |  141 ++++++++++++++++++++++++++++++++++---------
 net/sctp/sm_statetable.c   |   18 +++---
 net/sctp/socket.c          |    8 +-
 11 files changed, 503 insertions(+), 108 deletions(-)

You may pull from there is you wish.

-vlad
