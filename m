From: Andy Grover <agrover@redhat.com>
Subject: IP_FREEBIND and binding to in-use addr:ports
Date: Wed, 06 Feb 2013 16:47:20 -0800
Message-ID: <5112F998.8050605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: target-devel <target-devel@vger.kernel.org>
Return-path: <target-devel-owner@vger.kernel.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, this is weird:

https://bugzilla.redhat.com/show_bug.cgi?id=908368

It appears you can listen on the same address:port if you do it from a 
different iscsi target, or even a different tpg (so there are no 
configfs name collisions). I believe this is because we are setting 
IP_FREEBIND sockopt, so we can configure listening on iscsi portals (aka 
ip:port) before the IP is assigned.

from ip(7):
IP_FREEBIND (since Linux 2.4)
If enabled, this boolean option allows binding to an IP address that is
nonlocal or does not (yet) exist.  This permits listening on a socket,
without requiring the underlying network interface or the specified
dynamic IP address to be up at the time that the application is trying
to bind to it.  This option is the per-socket equivalent of the
ip_nonlocal_bind /proc interface described below.

This doesn't say anything about if the address:port is already in use. 
Dave/netdev, should the network stack be returning an error when 
attempting to bind to an address:port already in use even if IP_FREEBIND 
is set, or should the caller be checking for this before trying to 
kernel_bind()?

Or is something else the issue?

Thanks -- Regards -- Andy

p.s. see drivers/target/iscsi/iscsi_target_login.c line ~846 for caller 
code.
