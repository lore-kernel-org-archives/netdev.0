From: Iago Abal <iari@itu.dk>
Subject: Potential double mutex_lock bug in net/ceph/auth.c
Date: Mon, 27 Jun 2016 10:22:22 +0200
Message-ID: <CAGbDTvo5zF_vO7KwG8frD7H0gf3fkJc_oTXiZ=tKbiD9GpPXmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Sage Weil <sage@inktank.com>, Alex Elder <elder@inktank.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0102.outbound.protection.outlook.com ([157.56.112.102]:25568
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750736AbcF0I46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 04:56:58 -0400
Received: by mail-wm0-f49.google.com with SMTP id r201so103383316wme.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 01:23:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm testing a static bug finder (EBA) on Linux 4.7 release candidates
and I may have found a potential double lock:

  Double lock in net/ceph/auth.c
  second lock at 108: mutex_lock(& ac->mutex); [ceph_auth_build_hello]
  after calling from 263: ret = ceph_auth_build_hello(ac, msg_buf, msg_len);
  if ! ac->protocol -> true at 262
  first lock at 261: mutex_lock(& ac->mutex); [ceph_build_auth]

This seems to have been introduced by commit e9966076cdd9 ("libceph:
wrap auth methods in a mutex").

I hope it helps!

Thanks,

-- iago
