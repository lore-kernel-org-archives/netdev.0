From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 iproute2 0/3] ss: Add support to filter by device
Date: Mon, 27 Jun 2016 11:34:22 -0700
Message-ID: <1467052465-14488-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35179 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0Seg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:34:36 -0400
Received: by mail-pf0-f172.google.com with SMTP id c2so64343308pfa.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:34:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for specifying device name in the filter to ss.
The kernel does not provide support for iface filtering, so if
the user specifies 'dev == NAME' or 'dev != NAME' all filtering
is done in userspace.

I will send a patch to add support for iface filtering in the kernel,
but the reality is that ss will need to accommodate both (ie., lack of
kernel support) for some time - which this set provides.

v2
- fixed checkpatch errors and warnings

David Ahern (3):
  ss: Refactor inet_show_sock
  ss: Allow ssfilter_bytecompile to return 0
  ss: Add support to filter on device

 misc/ss.c       | 159 +++++++++++++++++++++++++++++++++++++++++---------------
 misc/ssfilter.h |   2 +
 misc/ssfilter.y |  22 +++++++-
 3 files changed, 140 insertions(+), 43 deletions(-)

-- 
2.1.4
