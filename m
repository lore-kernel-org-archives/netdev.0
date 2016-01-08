From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [iproute PATCH v3 2/2] ss: support closing inet sockets via SOCK_DESTROY.
Date: Fri,  8 Jan 2016 17:32:35 +0900
Message-ID: <1452241957-18854-1-git-send-email-lorenzo@google.com>
References: <CAKD1Yr1VQxVkQKpGxrtGmWd=_Z9Q2eBp1L313bqSddDXG9nNxg@mail.gmail.com>
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36197 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbcAHIcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 03:32:43 -0500
Received: by mail-pf0-f180.google.com with SMTP id n128so6745828pfn.3
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 00:32:43 -0800 (PST)
In-Reply-To: <CAKD1Yr1VQxVkQKpGxrtGmWd=_Z9Q2eBp1L313bqSddDXG9nNxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new version uses rtnl_talk as requested. It solves the
problem of spurious error messages by making rtnl_talk not print
any netlink-returned errors when operating on a NETLINK_SOCK_DIAG
socket.

Because there is currently no code that calls rtnl_talk on a
NETLINK_SOCK_DIAG socket, this does not affect existing
behaviour. The code in this patchset prints netlink errors by
itself, and any future code that does this will need to be
responsible for doing the same.
