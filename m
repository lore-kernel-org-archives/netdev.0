From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 4133] New: ipsec with automatic SA-generation; first
 connect fails
Date: Mon, 31 Jan 2005 08:32:02 -0800
Message-ID: <20050131083202.0606fbc2@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 30 Jan 2005 05:12:49 -0800
From: bugme-daemon@osdl.org
To: shemminger@osdl.org
Subject: [Bug 4133] New: ipsec with automatic SA-generation; first connect fails


http://bugme.osdl.org/show_bug.cgi?id=4133

           Summary: ipsec with automatic SA-generation; first connect fails
    Kernel Version:  version 2.6.7  (gcc-Version 3.3.4 (Debian 1:3.3.4-
                    6sarge1))
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: werner.baumann@onlinehome.de


Distribution: Debian GNU/Linux Sarge
Hardware Environment: AMD Athlon
Software Environment: libc-2.3.2.so, KAME IPSec-Tools (setkey and racoon)
Problem Description:
When configuring IPSec with automatic SA-establishment by racoon (or any other
IKE-daemon), as long as the SA is not established, the first attempt to connect
fails, while the SA is established after this correctly. The second attempt is
successfull. But meanwhile most aplications inform the user, that there is
something wrong with the connection. So the user will not try again, but maybe
instead will mix up his configuration.
Steps to reproduce:
- configure a Security Policy for connections to some peer (on both sides)
- configure racoon to establish SAs for this policy and start racoon
- try to connect (using telnet or some other application)
- connection will fail with some error-message "temporarily unavailable" or even
"connection refused"
- try again and the connection will succed (SA is established as displayed by
setkey -D)
I also tried a simple connect-Programm: it showed that the first call to the
connect()-function fails with errno EAGAIN. Allthough this errno seems quiet
reasonable to me, most applications don't try AGAIN, but instead confuse the user.
I think it would be desirable that the call to connect() would not fail, but
instead be delayed until the SA is established. Only if this is not possible
within some timeout, connect() should fail.
I think this behaviour would also better math RFC 2401, 5.1 Outbound IP Traffic
Processing, especially 5.1.1

I don't know whether this is an issue of kernel or just of glibc.

Thanks for kernel-ipsec anyway
Werner

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.


-- 
Stephen Hemminger	<shemminger@osdl.org>
