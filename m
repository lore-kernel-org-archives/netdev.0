From: David Stevens <dlstevens@us.ibm.com>
Subject: MLDv2 MRC timer wrong units [PATCH]
Date: Tue, 18 Nov 2003 18:19:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF827DB90A.DAAAB15E-ON88256DE3.0005C3DE@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE770DF96454E8f9e8a93df938690918c07BBE770DF96454E"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE770DF96454E8f9e8a93df938690918c07BBE770DF96454E
Content-type: text/plain; charset=US-ASCII





The MLD max response code is computing in units of 1/10th second,
as in IGMPv3, but for MLD, it should be in milliseconds. Patch below.

                        +-DLS

--- linux-2.6.0-test9-bk12/net/ipv6/mcast.c     2003-11-07 14:13:21.000000000 -0800
+++ linux-2.6.0-test9-bk12F1/net/ipv6/mcast.c   2003-11-18 16:55:07.801413776 -0800
@@ -1040,7 +1040,7 @@
            /* MLDv1 router present */

            /* Translate milliseconds to jiffies */
-           max_delay = ntohs(hdr->icmp6_maxdelay)*(HZ/10);
+           max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;

            switchback = (idev->mc_qrv + 1) * max_delay;
            idev->mc_v1_seen = jiffies + switchback;
@@ -1052,7 +1052,7 @@
            /* clear deleted report items */
            mld_clear_delrec(idev);
      } else if (len >= 28) {
-           max_delay = MLDV2_MRC(ntohs(mlh2->mrc))*(HZ/10);
+           max_delay = (MLDV2_MRC(ntohs(mlh2->mrc))*HZ)/1000;
            if (!max_delay)
                  max_delay = 1;
            idev->mc_maxdelay = max_delay;

(See attached file: mld2fix.patch)
--0__=07BBE770DF96454E8f9e8a93df938690918c07BBE770DF96454E
Content-type: application/octet-stream;
	name="mld2fix.patch"
Content-Disposition: attachment; filename="mld2fix.patch"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMTIvbmV0L2lwdjYvbWNhc3QuYwkyMDAzLTExLTA3IDE0
OjEzOjIxLjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjAtdGVzdDktYmsxMkYxL25ldC9p
cHY2L21jYXN0LmMJMjAwMy0xMS0xOCAxNjo1NTowNy44MDE0MTM3NzYgLTA4MDAKQEAgLTEwNDAs
NyArMTA0MCw3IEBACiAJCS8qIE1MRHYxIHJvdXRlciBwcmVzZW50ICovCiAKIAkJLyogVHJhbnNs
YXRlIG1pbGxpc2Vjb25kcyB0byBqaWZmaWVzICovCi0JCW1heF9kZWxheSA9IG50b2hzKGhkci0+
aWNtcDZfbWF4ZGVsYXkpKihIWi8xMCk7CisJCW1heF9kZWxheSA9IChudG9ocyhoZHItPmljbXA2
X21heGRlbGF5KSpIWikvMTAwMDsKIAogCQlzd2l0Y2hiYWNrID0gKGlkZXYtPm1jX3FydiArIDEp
ICogbWF4X2RlbGF5OwogCQlpZGV2LT5tY192MV9zZWVuID0gamlmZmllcyArIHN3aXRjaGJhY2s7
CkBAIC0xMDUyLDcgKzEwNTIsNyBAQAogCQkvKiBjbGVhciBkZWxldGVkIHJlcG9ydCBpdGVtcyAq
LwogCQltbGRfY2xlYXJfZGVscmVjKGlkZXYpOwogCX0gZWxzZSBpZiAobGVuID49IDI4KSB7Ci0J
CW1heF9kZWxheSA9IE1MRFYyX01SQyhudG9ocyhtbGgyLT5tcmMpKSooSFovMTApOworCQltYXhf
ZGVsYXkgPSAoTUxEVjJfTVJDKG50b2hzKG1saDItPm1yYykpKkhaKS8xMDAwOwogCQlpZiAoIW1h
eF9kZWxheSkKIAkJCW1heF9kZWxheSA9IDE7CiAJCWlkZXYtPm1jX21heGRlbGF5ID0gbWF4X2Rl
bGF5Owo=

--0__=07BBE770DF96454E8f9e8a93df938690918c07BBE770DF96454E--
