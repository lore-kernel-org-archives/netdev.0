From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196671] New: TUN(GET/ATTACH/DETACH)FILTER ioctls fail in a
 x86-32 process on an x86-64 kernel
Date: Tue, 15 Aug 2017 09:15:18 -0700
Message-ID: <20170815091518.07ebcbcd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35776 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdHOQPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 12:15:21 -0400
Received: by mail-pg0-f48.google.com with SMTP id v189so8314694pgd.2
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 09:15:20 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id n1sm19997790pfj.46.2017.08.15.09.15.20
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 Aug 2017 09:15:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 15 Aug 2017 14:21:36 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196671] New: TUN(GET/ATTACH/DETACH)FILTER ioctls fail in a x86-32 process on an x86-64 kernel


https://bugzilla.kernel.org/show_bug.cgi?id=196671

            Bug ID: 196671
           Summary: TUN(GET/ATTACH/DETACH)FILTER ioctls fail in a x86-32
                    process on an x86-64 kernel
           Product: Networking
           Version: 2.5
    Kernel Version: 4.12.0 (Linus)
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: robert@ocallahan.org
        Regression: No

These ioctls take a 'struct sock_fprog' but there's no 32-bit compat code,
which has two consequences:

1) The ioctl numbers are incorrect for 32-bit processes running on a 64-bit
kernel. The userspace ioctl numbers use an 8-byte 'size' field but the kernel
expects a 16-byte size field, so the ioctls fail with EINVAL. You can hack
around this by handcoding the 64-bit ioctl number.

2) Userspace must supply a sock_fprog with the 64-bit layout.

Of course these workarounds assume you're running on a 64-bit kernel, so
they're no good if you might be running on a 32-bit kernel.

-- 
You are receiving this mail because:
You are the assignee for the bug.
