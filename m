From: Dan Carpenter <error27@gmail.com>
Subject: bug report: xfrm: potential null deref in xfrm_bundle_lookup()
Date: Sat, 22 May 2010 22:24:30 +0200
Message-ID: <20100522202430.GN22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47344 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978Ab0EVUZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 16:25:02 -0400
Received: by vws9 with SMTP id 9so1653697vws.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 13:25:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a smatch thing.  I couldn't tell if it was a real issue so I
thought I would send this mail to the experts.  :)

net/xfrm/xfrm_policy.c +1679 xfrm_bundle_lookup(51)
	error: we previously assumed 'xdst' could be null.
  1672          new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family, dst_orig);
  1673          if (IS_ERR(new_xdst)) {
  1674                  err = PTR_ERR(new_xdst);
  1675                  if (err != -EAGAIN)
  1676                          goto error;
  1677                  if (oldflo == NULL)
  1678                          goto make_dummy_bundle;
  1679                  dst_hold(&xdst->u.dst);
                                  ^^^^^^^^^^^
	Can xdst be NULL here?  It would have to be something like
	oldflo gets passed in as null and __xfrm_policy_lookup() fails.

  1680                  return oldflo;
  1681          }

regards,
dan carpenter
