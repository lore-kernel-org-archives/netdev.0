From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6502] New: SIOCSIFHWBROADCAST needs compat
 layer
Date: Sat, 6 May 2006 09:27:51 -0700
Message-ID: <20060506092751.5077857e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64942 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750759AbWEFQ2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 12:28:03 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sat, 6 May 2006 08:24:25 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6502] New: SIOCSIFHWBROADCAST needs compat layer


http://bugzilla.kernel.org/show_bug.cgi?id=6502

           Summary: SIOCSIFHWBROADCAST needs compat layer
    Kernel Version: 2.6.15
            Status: NEW
          Severity: normal
             Owner: ak@suse.de
         Submitter: Alexandra.Kossovsky@oktetlabs.ru


Most recent kernel where this bug did not occur: all kernels has this problem;
I've tested 2.6.8, 2.6.9, 2.6.15

Distribution:
Hardware Environment: ethernet interface
Software Environment: 32-bit libc with 64-bit kernel
Problem Description:
32-bit program running with 64-bit kernel fails to set hardware broadcast
address via ioctl(SIOCSIFHWBROADCAST).

Steps to reproduce:
Compile the following sample program:
#include <stdio.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <linux/if.h>

main()
{
    int             s = socket(AF_INET, SOCK_DGRAM, 0);
    struct ifreq    req;
    int             rc;
    
    if (s < 0)
    {
        perror("failed to open socket");
        return -1;
    }
    strcpy(req.ifr_name, "eth0");
    req.ifr_hwaddr.sa_family = AF_LOCAL;
    memset(req.ifr_hwaddr.sa_data, 0xff, 6);
    rc = ioctl(s, SIOCSIFHWBROADCAST, &req);
    if (rc != 0)
    {
        perror("ioctl failed");
        return -1;
    }
    printf("ioctl(SIOCSIFHWBROADCAST) passed\n");
    return 0;
}

When compiled to 64-bit binary, it works OK:
ioctl(SIOCSIFHWBROADCAST) passed
When compiled to 32-bit binary, it does not work:
ioctl failed: Invalid argument

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
