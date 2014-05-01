From: Daniel Borkmann <dborkman@redhat.com>
Subject: Fwd: [Bug 75221] New: CONFIG_PROC_SYSCTL is required for networking
Date: Thu, 01 May 2014 13:38:25 +0200
Message-ID: <53623231.6020907@redhat.com>
References: <bug-75221-65011@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbaEALia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 07:38:30 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s41BcUxX014540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 1 May 2014 07:38:30 -0400
Received: from [10.36.6.67] (vpn1-6-67.ams2.redhat.com [10.36.6.67])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s41BcQgH002662
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 1 May 2014 07:38:27 -0400
In-Reply-To: <bug-75221-65011@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [Bug 75221] New: CONFIG_PROC_SYSCTL is required for networking
Date: Thu, 01 May 2014 10:17:24 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: dborkman@redhat.com

https://bugzilla.kernel.org/show_bug.cgi?id=75221

             Bug ID: 75221
            Summary: CONFIG_PROC_SYSCTL is required for networking
            Product: Networking
            Version: 2.5
     Kernel Version: 3.14.2
           Hardware: All
                 OS: Linux
               Tree: Mainline
             Status: NEW
           Severity: normal
           Priority: P1
          Component: Other
           Assignee: shemminger@linux-foundation.org
           Reporter: stefan@konink.de
         Regression: No

I am in the proces of building an embedded kernel which I wanted to limit in
both functionality and memory. For this reason I disabled CONFIG_PROC_SYSCTL. I
have figured out the hard way that this functionality implements the successful
randomisation of source ports, it might be responsible for the initialisation
of net.ipv4.ip_local_port_range.

Effectively, booting a kernel with ip=dhcp works. Ping-pong (ICMP) to and from
an address works. DNS queries (UDP/53) don't because the source port remains 0,
a connection to a typical webserver also seems to result in a no reply
situation.

-- 
You are receiving this mail because:
You are watching the assignee of the bug.
