From: Jos Vos <jos@xos.nl>
Subject: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sat, 04 Dec 2004 00:25:39 +0100
Message-ID: <200412032325.iB3NPdG04693@xos037.xos.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I have a problem with an Intel Pro/1000 MT 4-port card in a Supermicro
(non-HT) Pentium 4 system using RHEL3 (2.4.21 kernel "the RH way") with
the e1000 driver (I tried both the version supplied by RH and the
newest 5.5.4 driver):

(1)
With a non-SMP kernel, the whole system freezes instantaneously when
configuring one of in the four interfaces.

(2)
After disabling the USB controller, all interfaces can be configured,
but only one of them actually works.  Via the others, I can sent
packets, but do not receive incoming packages (possible IRQ problem).

(3)
Using a SMP-kernel, two of the four interfaces can be configured and
work correctly.  For the other two ports, ifconfig gives the
error "SIOCSIFFLAGS: Invalid argument".  Stracing ifconfig says:

  socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
  ...
  ioctl(4, SIOCSIFADDR, 0xbfffc210)       = 0
  ioctl(4, SIOCGIFFLAGS, 0xbfffc140)      = 0
  ioctl(4, SIOCSIFFLAGS, 0xbfffc140)      = -1 EINVAL (Invalid argument)

Stracing ifconfig for an interface that works shows similar lines,
but then the second SIOCSIFFLAGS ioctl succeeds.

Supermicro suggest to change the non-HT P4 CPU by a HT one, but I
personally do not believe that this will change the situation of the
SMP kernel as described above.

Any suggestions how to solve this are welcome.  I can provide more
information if needed.

Thanks,

--
--    Jos Vos <jos@xos.nl>
--    X/OS Experts in Open Systems BV   |   Phone: +31 20 6938364
--    Amsterdam, The Netherlands        |     Fax: +31 20 6948204
