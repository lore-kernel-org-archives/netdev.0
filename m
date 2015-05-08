From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 97961] New: macvtap does not transport IPv4 multicast
 packets
Date: Fri, 8 May 2015 12:51:42 -0700
Message-ID: <20150508125142.5dadf9e7@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33120 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbbEHTvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 15:51:38 -0400
Received: by pdbnk13 with SMTP id nk13so95863203pdb.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 12:51:37 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id b10sm6008995pdj.0.2015.05.08.12.51.37
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 12:51:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 8 May 2015 19:50:20 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 97961] New: macvtap does not transport IPv4 multicast packets


https://bugzilla.kernel.org/show_bug.cgi?id=97961

            Bug ID: 97961
           Summary: macvtap does not transport IPv4 multicast packets
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: mh+kernel-bugzilla@zugschlus.de
        Regression: No

Hi,

I have a system running Debian Jessie and kernel 4.0.2 (self-built). When I
start a VM (also Debian Jessie) in kvm which has its network connected via
macvtap, IPv4 multicast packets do not show up on the macvtap interface and
also not inside the VM. This can easily be observed when avahi is in use.

tcpdump on enp3s0:
21:44:24.855171 IP6 2a01:238:4071:321e:224:d7ff:fed0:5adc.5353 > ff02::fb.5353:
0 A (QM)? parada.local. (30)
21:44:24.855242 IP 192.168.251.21.5353 > 224.0.0.251.5353: 0 A (QM)?
parada.local. (30)
21:44:25.856546 IP6 2a01:238:4071:321e:224:d7ff:fed0:5adc.5353 > ff02::fb.5353:
0 A (QM)? parada.local. (30)
21:44:25.856617 IP 192.168.251.21.5353 > 224.0.0.251.5353: 0 A (QM)?
parada.local. (30)
21:44:27.858923 IP6 2a01:238:4071:321e:224:d7ff:fed0:5adc.5353 > ff02::fb.5353:
0 A (QM)? parada.local. (30)
21:44:27.858995 IP 192.168.251.21.5353 > 224.0.0.251.5353: 0 A (QM)?
parada.local. (30)

tcpdump on macvtap0:
21:44:40.113076 IP6 2a01:238:4071:321e:224:d7ff:fed0:5adc.5353 > ff02::fb.5353:
0 A (QM)? parada.local. (30)
21:44:41.114809 IP6 2a01:238:4071:321e:224:d7ff:fed0:5adc.5353 > ff02::fb.5353:
0 A (QM)? parada.local. (30)
21:44:43.117490 IP6 2a01:238:4071:321e:224:d7ff:fed0:5adc.5353 > ff02::fb.5353:
0 A (QM)? parada.local. (30)

The avahid on the VM does not answer the IPv6 packets since it is configured
not to answer A queries over IPv6.

Using a regular bridge to connect the VM via the shared device model works.

I do not know whether this is a regression since I never tried with older
kernels, I have never tried macvtap before.

Greetings
Marc

-- 
You are receiving this mail because:
You are the assignee for the bug.
