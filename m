From: Jonathan Marler <johnnymarler@gmail.com>
Subject: epoll, missed opportunity?
Date: Fri, 18 Sep 2015 22:51:08 -0600
Message-ID: <CACKT+AqSZS+o-C2osio7PWy+2bKuveT-uU2znSOHBjNRKxc0-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36768 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbISEvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 00:51:09 -0400
Received: by obbmp4 with SMTP id mp4so17073780obb.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 21:51:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm curious why there wasn't another field added to the epoll_event
struct for the application to store the descriptor's context. Any
useful multi-plexing application will have a context that will need to
be retrieved every time a descriptor needs to be serviced. Since the
epoll api has no way of storing this context, it has to be looked up
using the descriptor, which will take more time/memory as the number
of descriptors increase. The memory saved from omitting this context
can't be worth it since you'll have to allocate the memory in the
application anyway, plus you're now adding the extra lookup.

This "lookup" problem has always existed in multi-plexed applications.
It was impossible to fix with older polling interfaces, however, since
epoll is stateful, it provides an opportunity to fix this problem by
storing the descriptor context in epoll's "state". What was the reason
for not doing this?  Was it an oversight or am I missing something?
