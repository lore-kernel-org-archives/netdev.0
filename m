From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v4 0/2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Sat, 26 Sep 2015 18:50:41 -0400
Message-ID: <1443307843-16880-1-git-send-email-aconole@bytheb.org>
References: <20150924.121459.1016780653505420756.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33135 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbbIZWvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 18:51:03 -0400
Received: by qkdw123 with SMTP id w123so55217082qkd.0
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 15:51:02 -0700 (PDT)
In-Reply-To: <20150924.121459.1016780653505420756.davem@davemloft.net>
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

v2->v3:
 - Added Eric Dumazet's suggestion for #define to static inline
 - Fixed an issue calling unix_state_lock() with an invalid argument

v3->v4:
 - Eliminated an XXX comment
 - Changed from goto unlock to explicit unix_state_unlock() and break

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
