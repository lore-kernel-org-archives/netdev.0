From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v3 0/2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Mon, 21 Sep 2015 20:27:00 -0400
Message-ID: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
Cc: Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34529 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124AbbIVA1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:27:09 -0400
Received: by qgez77 with SMTP id z77so105039715qge.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 17:27:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set implements a bugfix for kernel.org bugzilla #12323, allowing
MSG_PEEK to return all queued data on the unix domain socket, not just the
data contained in a single SKB. 

This is the v3 version of this patch, which includes a suggested modification
by Eric Dumazet to convert the unix_sk() conversion macro to a static inline
function. These patches are independent and can be applied separately.

This set was tested over a 24-hour period, utilizing a loop continually 
executing the bugzilla issue attached python code. It was instrumented with
a pr_err_once() ([   13.798683] unix: went there at least one time).

Aaron Conole (2):
  [net] af_unix: Convert the unix_sk macro to an inline function for    
    type safety
  [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK
    flag

 include/net/af_unix.h |  6 +++++-
 net/unix/af_unix.c    | 19 +++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

-- 
1.9.1
