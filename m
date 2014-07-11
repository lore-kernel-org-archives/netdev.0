From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: FYI: Router causes TCP retransmits for windows hosts after
 "ip_forward: fix inverted local_df test"
Date: Fri, 11 Jul 2014 13:40:26 +0300
Message-ID: <CACVxJT9-eehBaHZQM4mTbUxP6EErurMiK=q2L32MV6MixQWL0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:40888 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbaGKKk2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 06:40:28 -0400
Received: by mail-la0-f45.google.com with SMTP id ty20so664189lab.32
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 03:40:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://bugzilla.kernel.org/show_bug.cgi?id=3D79891

Theodor Milkov 2014-07-10 13:20:06 UTC
Created attachment 142651 [details]
TCP retransmissions from a windows host

After upgrading a router to Linux 3.2.60 most windows machines behind
it started experiencing connection stalls. Downgrade to 3.2.59
resolved the problem. Using git bisect I pinpointed it to
"59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit",
which entered the kernel from here
http://marc.info/?l=3Dlinux-netdev&m=3D139949081418806&w=3D2

No connection problems for Linux hosts at all =E2=80=93 only windows. P=
lease,
find attached tcpdump packet capture demonstrating the bad behaviour.
[reply] [=E2=88=92] Comment 1 Theodor Milkov 2014-07-11 05:44:45 UTC
I wonder if this is the same bug discussed in the Debian bug tracker:
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D754294
