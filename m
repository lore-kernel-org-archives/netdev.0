From: Andrew Grover <andy.grover@gmail.com>
Subject: how expensive are mallocs?
Date: Tue, 24 Nov 2009 09:57:34 -0800
Message-ID: <c0a09e5c0911240957x45abfb26k1611e53f435e5179@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:54384 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245AbZKXR52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 12:57:28 -0500
Received: by pzk1 with SMTP id 1so4965189pzk.33
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 09:57:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How much effort generally makes sense to avoid mallocs? For example,
rds has a function that does a kmalloc for an array of scatterlist
entries, which is freed at the bottom of the function. We couldn't
allocate off the stack in all cases (too big), but we could allocate
an array of say 8 scatterlists, and use it if that's big enough,
falling back to kmalloc if it's not.

Is this a good idea?

Also, RDS has its own per-cpu page remainder allocator (see
net/rds/page.c) for kernel send buffers. Would cutting this code and
just using kmalloc be recommended? Doesn't SL?B already do per-cpu
pools?

Does this stuff even matter enough to rise above the noise in benchmarks?

Thanks -- Regards -- Andy
