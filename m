From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 19 Mar 2014 09:14:46 +0200
Message-ID: <CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:37751 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036AbaCSHOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 03:14:46 -0400
Received: by mail-qc0-f176.google.com with SMTP id m20so9141406qcx.7
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 00:14:46 -0700 (PDT)
In-Reply-To: <OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 10:55:16AM -0600, David Stevens wrote:
>
> Wouldn't it be better to:
>
> 1) make sure all of vxlan_dev is initialized before use,
> especially default_dst
> 2) change the v6 code to check for AF_INET6 too, and do
> nothing if not set. If not set by the admin, the family of
> default_dst would then be AF_UNSPEC and not match.

The family of default dst is implicitly initailized to AF_UNSPEC because
if kzalloc :)

I agree that explicit check for AF_INET6 is much better than fallthrough
with simple 'else' clause and I can send a patch that makes the checks
for IPv6 as well as default_dst initialization explicit

However, for the particular case in vxlan_rcv, checking the packet
version seems to me semantically more correct than comparing default_dst
protocol family with AF_INET or AF_INET6.

> +-DLS

--
Sincerely yours,
Mike.
