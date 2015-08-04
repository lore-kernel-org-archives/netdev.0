From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 4 Aug 2015 10:44:02 +0300
Message-ID: <20150804074402.GA10867@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47571 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbbHDHop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 03:44:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Roopa,

I have a concern about patch bf21563acc1d: "af_mpls: fix undefined
reference to ip6_route_output" from Jul 30, 2015.

net/mpls/af_mpls.c
   450  
   451          dev = find_outdev(net, cfg);
   452          if (IS_ERR(dev)) {

find_outdev() used to return NULL pointers but now it only returns NULL
if cfg->rc_via_table == NEIGH_LINK_TABLE or dev_get_by_index() fails.
I think it could lead to a NULL dereference and we don't check for that
here.

Returning a mix of error pointers and NULL is bad style, it needs a big
comment at the top of the function if it's deliberate.

   453                  err = PTR_ERR(dev);
   454                  dev = NULL;
   455                  goto errout;
   456          }

regards,
dan carpenter
