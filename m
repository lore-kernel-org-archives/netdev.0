From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Thu, 10 Aug 2006 11:07:35 -0700
Message-ID: <OF820B5A3B.88664E29-ON882571C6.0062D3AA-882571C6.0063924D@us.ibm.com>
References: <019901c6bc75$872ee1f0$2303a8c0@mruzicka>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:1180 "EHLO e33.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422679AbWHJSIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 14:08:20 -0400
In-Reply-To: <019901c6bc75$872ee1f0$2303a8c0@mruzicka>
To: Michal Ruzicka <michal.ruzicka@comstar.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal,
        This looks correct, but I think a better way to do it is:

        in_dev = inetdev_by_index(...)
        (void) ip_mc_leave_src()
        if (in_dev) {
                ip_mc_dec_group()
                in_dev_put()
        }

        That way, sflist internal details aren't visible at this
level, and ip_mc_leave_src() collapses to the sock_kfree_s()
when in_dev is NULL.
        Also, ip_mc_leave_group() has the same issue; looks
like it just needs the "if (in_dev)" removed before the call to
ip_mc_leave_src().

                                        +-DLS

