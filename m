From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3320] New: 2.6 kernel trigger happy to load
 ipv6 module
Date: Tue, 31 Aug 2004 11:52:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831115241.1cc516d3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 31 Aug 2004 09:07:28 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3320] New: 2.6 kernel trigger happy to load ipv6 module


http://bugme.osdl.org/show_bug.cgi?id=3320

           Summary: 2.6 kernel trigger happy to load ipv6 module
    Kernel Version: 2.6.8.1
            Status: NEW
          Severity: normal
             Owner: other_modules@kernel-bugs.osdl.org
         Submitter: alex@milivojevic.org


Distribution: Fedora Core 2
Hardware Environment: i386
Software Environment: kernel-2.6.8.1 modutils-2.4.26-16
Problem Description:
Seems that triggering of automatic module loading has changed since 2.4 kernels.
 ipv6 module gets automatically loaded even in situations when it isn't really
needed.  It seems that ipv6 module will get loaded as soon as IPv6 aware
application binds a port (most of standard daemons with standard configurations
in most (all? some?) distributions).  I haven't checked if IPv6 aware client
application will trigger autoloading of ipv6 module.  This is very different
behaviour than in 2.4 that never autoloads ipv6 module (scripts in
/etc/sysconfig/network-scripts were supposed to load it manually if IPv6 was to
be configured on the box).  Because of this, all network interfaces get
autoconfigured IPv6 addresses even when user doesn't want/need them (link local
for Ethernet interfaces, and loopback gets ::1).  I've noticed this first on
Fedora Core 1 after I upgraded kernel from 2.4 series to 2.6 series (I believe
it was either one of 2.6.0-rc or maybe final 2.6.0, not sure).  At first I
tought it was a problem with network initialization scripts in
/etc/sysconfig/network-scripts.  However, after I reinvestigated the problem
(now in Fedora Core 2 with 2.6.5 up to 2.6.8.1), I found that it is triggered by
2.6 kernel.  For some people this might present security issue.  Most firewall
configurations are not written with IPv6 in mind.  Depending of
firewall/services configuration on particular host this can open new vector of
attack for malicious user.  An example would be if firewall rules prevent IPv4
access to (potentially with security flaw and still unpatched) service on WAN
and loopback interfaces, but allow access from LAN.  If attacker gains "regular"
user access to the machine, he can exploit flaw in the service by connecting to
it using IPv6 over loopback.  Somebody with more imagination than me could
probably find more dangeraous vector.  I don't know much about IPv6, so I don't
know if and how automatically assigned link local addresses could be used to
bypass IPv4-only firewall from WAN/LAN.

Steps to reproduce:
No steps needed (at least on Fedora Core with 2.6 kernel).  Just run lsmod or
ifconfig, and you'll see that ipv6 is loaded, and IPv6 addresses automatically
assigned to interfaces.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
