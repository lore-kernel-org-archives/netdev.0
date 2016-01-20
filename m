From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 111041] New: random openssh connection failure during
 connection to server
Date: Wed, 20 Jan 2016 09:55:51 -0800
Message-ID: <20160120095551.4a586d27@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33809 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934556AbcATRzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 12:55:47 -0500
Received: by mail-pa0-f41.google.com with SMTP id uo6so8351169pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 09:55:47 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id rt6sm50608908pab.17.2016.01.20.09.55.46
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 09:55:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 20 Jan 2016 10:14:17 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 111041] New: random openssh connection failure during connection to server


https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_show-5Fbug.cgi-3Fid-3D111041&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=Jk3RwPbncUW6RyLfcTeu44MAZ0LFZm_HFxRIcPFJaEs&s=Jrbgmvu1hu8KrQlA3sTLXDCgTkW3xtWM9UuXUmMnf9M&e= 

            Bug ID: 111041
           Summary: random openssh connection failure during connection to
                    server
           Product: Networking
           Version: 2.5
    Kernel Version: 4.4.0
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: hydrapolic@gmail.com
        Regression: No

It's sometimes impossible to connect to a server running Gentoo Linux with
kernel 4.4 using ssh. The problem is only the connection, it fails a few times
but then it goes fine and ssh works as expected.

OpenSSH_7.1p2-hpn14v10, OpenSSL 1.0.2e 3 Dec 2015
debug1: Reading configuration data /etc/ssh/ssh_config
debug2: ssh_connect: needpriv 0
debug1: Connecting to 10.0.0.5 [10.0.0.5] port 22.
debug1: Connection established.
debug1: Enabling compatibility mode for protocol 2.0
write: Connection reset by peer

Or alternatively it fails with "ssh_exchange_identification: read: Connection
reset by peer".

We were able to reproduce this problem with random clients, Gentoo, Ubuntu,
Debian, random kernels. It's interesting that only 1 client doesn't have a
problem to connect to the server - a system with Gentoo Linux Hardened 4.1
(using the same openssh version).

The server is a Supermicro X10DRW, Intel PCI-Express Gigabit Ethernet (igb)
networking. Two ethernet ports were connected to bond and that to a bridge for
xen. I've also tried without bond and without any iptables rules, it didn't
help. This setup works without any modification on kernel 4.1.15.

A Gentoo forum post: https://urldefense.proofpoint.com/v2/url?u=https-3A__forums.gentoo.org_viewtopic.php-3Fp-3D7868744&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=Jk3RwPbncUW6RyLfcTeu44MAZ0LFZm_HFxRIcPFJaEs&s=SuurWudhyHYuvvaWUtAMY_Yihv7qKIBzXVesBCNhj04&e= 

-- 
You are receiving this mail because:
You are the assignee for the bug.
