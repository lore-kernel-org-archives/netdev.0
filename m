From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4001] New: can't lower mtu of via_velocity
Date: Thu, 6 Jan 2005 16:22:47 -0800
Message-ID: <20050106162247.064add04.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fadlouni@hotmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 6 Jan 2005 15:30:14 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4001] New: can't lower mtu of via_velocity


http://bugme.osdl.org/show_bug.cgi?id=4001

           Summary: can't lower mtu of via_velocity
    Kernel Version: 2.6.10
            Status: NEW
          Severity: high
             Owner: jgarzik@pobox.com
         Submitter: fadlouni@hotmail.com


Distribution: 
gentoo 
Hardware Environment: 
amd64
asus av8 motherboard
Software Environment:
x86_64 AMD Athlon(tm) 64 Processor 3500+ AuthenticAMD GNU/Linux
gcc 3.4.3
sys-libs/glibc-2.3.4.20041102
net-tools-1.60-r9
ifconfig 1.42


Problem Description:
trying to lower mtu of eth0 to anything lower than 1500 doesn't work:
/usr/src:/whoami
root
/usr/src:/ifconfig eth0 mtu 1499
SIOCSIFMTU: Invalid argument

/var/log/messages shows:
 eth0: Invalid MTU.

via-velocity.h has:
#define VELOCITY_MIN_MTU    (1514-14)

via-velocity.c has:

if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n", 
				vptr->dev->name);


this explains the reason. however i tried changing the VELOCITY_MIN_MTU
to something like 64, then recompiled. now ifconfig accepts mtu 1400.
but nothing works afterwards. a simple ping to the gateway fails.

Steps to reproduce:
load via-velocity module, then
/usr/src:/ifconfig eth0 mtu 1499
SIOCSIFMTU: Invalid argument

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
