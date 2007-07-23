From: Adrian Bunk <bunk@stusta.de>
Subject: net/9p/mux.c: use-after-free
Date: Mon, 23 Jul 2007 03:20:14 +0200
Message-ID: <20070723012014.GV26212@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Latchesar Ionkov <lucho@ionkov.net>,
	Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:41543 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751401AbXGWBUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 21:20:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted the following use-after-free
in net/9p/mux.c:

<--  snip  -->

...
struct p9_conn *p9_conn_create(struct p9_transport *trans, int msize,
                                    unsigned char *extended)
{
...
        if (!m->tagpool) {
                kfree(m);
                return ERR_PTR(PTR_ERR(m->tagpool));
        }
...

<--  snip  -->


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

