From: Olaf Hering <olh@suse.de>
Subject: pppoe handles MOD_DEC_USE_COUNT incorrectly
Date: Sun, 11 May 2003 22:27:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030511202728.GA9018@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

it seems pppoe does increase its usage count with each reconnect, but it
never releases it when the ppp connection dies.

Linux version 2.4.20-ibook (builds@ibook) (gcc version 3.2.1 20021026 (prerelease)) #1 Sam Dez 7 19:52:20 CET 2002
Module                  Size  Used by    Not tainted
nfsd                   71364   4  (autoclean)
keyspan                96308   1 
usbserial              20736   0  [keyspan]
ipt_REJECT              3280   2  (autoclean)
ipt_LOG                 3312   1  (autoclean)
ipt_state                752   4  (autoclean)
ipt_TCPMSS              2512   1  (autoclean)
iptable_filter          1904   1  (autoclean)
ipt_MASQUERADE          1664   3  (autoclean)
ip_conntrack_irc        3072   1  (autoclean)
ip_nat_irc              2512   0  (unused)
ip_conntrack_ftp        4096   1  (autoclean)
ip_nat_ftp              3264   0  (unused)
iptable_nat            17140   3  [ipt_MASQUERADE ip_nat_irc ip_nat_ftp]
ip_tables              13936   9  [ipt_REJECT ipt_LOG ipt_state ipt_TCPMSS iptable_filter ipt_MASQUERADE iptable_nat]
ip_conntrack           20604   4  [ipt_state ipt_MASQUERADE ip_conntrack_irc ip_nat_irc ip_conntrack_ftp ip_nat_ftp iptable_nat]
sbp2                   17696   0  (unused)
pppoe                   9168   3 
pppox                   1464   1  [pppoe]
ppp_async               8336   0  (unused)
ppp_generic            24780   3  [pppoe pppox ppp_async]
slhc                    4272   0  [ppp_generic]
ide-scsi                9760   0 
sungem                 27348   1 
ohci1394               27984   0  (unused)
ieee1394               44792   0  [sbp2 ohci1394]


My DSL connection is terminated after 24h, now, after the reconnect:

--- /tmp/1      Sun May 11 21:21:04 2003
+++ /tmp/11     Sun May 11 21:41:00 2003
@@ -7,7 +7,7 @@
 ipt_state                752   4  (autoclean)
 ipt_TCPMSS              2512   1  (autoclean)
 iptable_filter          1904   1  (autoclean)
-ipt_MASQUERADE          1664   3  (autoclean)
+ipt_MASQUERADE          1664   4  (autoclean)
 ip_conntrack_irc        3072   1  (autoclean)
 ip_nat_irc              2512   0  (unused)
 ip_conntrack_ftp        4096   1  (autoclean)
@@ -16,7 +16,7 @@
 ip_tables              13936   9  [ipt_REJECT ipt_LOG ipt_state ipt_TCPMSS iptable_filter ipt_MASQUERADE iptable_nat]
 ip_conntrack           20604   4  [ipt_state ipt_MASQUERADE ip_conntrack_irc ip_nat_irc ip_conntrack_ftp ip_nat_ftp iptable_nat]
 sbp2                   17696   0  (unused)
-pppoe                   9168   3 
+pppoe                   9168   4 
 pppox                   1464   1  [pppoe]
 ppp_async               8336   0  (unused)
 ppp_generic            24780   3  [pppoe pppox ppp_async]

I tried to fix it myself, but its not obvious to me where to place the
MOD_DEC_USE_COUNT. I believe the socket is still active when the
connection terminates, and pppoe_sock_destruct() is not called.


Gruss Olaf

-- 
USB is for mice, FireWire is for men!
