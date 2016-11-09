From: Florian Fainelli <f.fainelli@gmail.com>
Subject: nf_nat_tftp broken in 4.8?
Date: Wed, 9 Nov 2016 12:40:02 -0800
Message-ID: <b3fb3d07-fb0b-e4a5-20fe-bdc2abc8f6fc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------D93A920BA017053A8998C73A"
Cc: pablo@netfilter.org
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34937 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbcKIUkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 15:40:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------D93A920BA017053A8998C73A
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Hi,

After updating my workstation from 4.4 to 4.8, which also serves as a
NAT gateway for local machines, I noticed that TFTP across this NAT box
broke:

- TFTP read request to the server, source port 3534
- server replies with a data packet to dst port 3534
- gateway sends an ICMP destination unreachable with port unreachable
along with the UDP data packet

I am currently bisecting this, but it is taking a lot longer to build
than I thought. Attached is the non-working case PCAP file for you to
look at.

There has not been a lot happening for net/netfilter/*tftp* between v4.4
and 4.8, so can you think about something in particular that could cause
that?

Thanks!
--
Florian

--------------D93A920BA017053A8998C73A
Content-Type: application/gzip;
 name="tftp-4.8pcapng.pcapng.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tftp-4.8pcapng.pcapng.gz"

H4sIAAAAAAAAA+2ab2ibRRzHf8/zJGmTNktWs7ZmwT6FDvrHZGnXdVXrlm6dxbLZB22rU7Tr
mriGpUnI0rqpYKR/WKul2RxFa2cfEJlaGW7sxQSFDTeGFWpBhNFXzx8j6xQ70Q1FsN49SWDq
08NCXt7BcXdP7p7v3eXD50WIxWq1HAOA/U01Tga1q5nCQTHsC4YHjvH1nkaP1123w304EA7E
gr0ABmiEloH+aG9PlK98OhgLHO3riR2p4us8dR4vX9kajPNPBgb5zvCRcOSlMP9iLNLPD6QH
VSgCcB7Oasm0+I0sqoF4n9eMnpjRk0JCPmTWmlCNpoew65URR+IdaVVAfVzB6X3ODsnzrl5n
RT7sBdiNAqB3I7/ZEp35zWId3WxdQI89czeACQcP98VDx7fW124d7A+h0JfdwXAwHvO7e2L9
EOmNB+JaDs4T2HSeD+X98t6FEg8a45pOSqfiPJb/eTvAoxu7CnAWzpztti6whd524PChRZlU
OYBbpZUR7XISDa8Cw3IGSNrkG1b4kYmKMptA83gbmlekoknOEhDVrvqiFQCb7AReKQO7WgaX
1W8hoaJjO5nChFooTSpwOyJv+NUjh+GgDLfLZTMag06x+UR55x6Dwj4+rNjQfgwgyH3s7HYb
JLwAHbWMb3jbGYCaCduk8oQredO1mEwx4JPg4KgE4rgEyaUUIy2lNpwek1nUciLqvz0mW2bG
ZFickJgPJxQQRBWkqdSbpbNo7QtyNdqnQZhKBUq3SKulV9RAhyiXd2yRPhBGpDxhRMkTrqms
uVNlD4jbGFOnynSJQ0b0LpvgXs5HezTZRdnIi/KXDnRHIKC5LQqD7gCdXcl+9rkDCmzCFzeN
i/slE7pDxzOzqUv2SYWxPyYx9k6JSY4l9PaQzTei8xnR+XAu89G4YoEO+QGAarM4LEWTk4oZ
nkX3D9OWT8aVVXFebetuV8rQOoB2uQxAcaJ9oe/WmeYI8xS6hyf/6xdL2tAY13/xe5ltqkJv
8THFp7L8clzDWbySskZZI7MWYv/pSszawunoToIrjZornblzZVHb+WaCKxs0fi1ZfsdHML97
qyi/lF99Vy5MX2he25XVVZor9+m6krJGWVuXK5VpSBBcadJceX/uXGl7yzdEcOUOjV9zlt/v
LmF+/7hD+aX86rtyF7t7iODKAc2VoOtKyhplbV2u/PpA8grBlXmaK0tz58qf3vjmKsGVjRq/
+Vl+585hfiuA8kv51XflzNTi1bVdWVODXbmpTdeVlDXK2v92ZTNi7Xo7zxFcma+5siQ3rsR5
hcuHTARXPqTxm5fld/kk5vcHF+WX8vtfV2KeTpn8JoIrF7ArHWd1XUlZo6yty5Xc3U9bCK40
a64szp0ro392txJc+bDGrynLb+pjzO8tjvJL+dV3ZXlFT+varnxwFLvyvhVdV1LWKGvrcmWo
wDdKcKVFc+Wm3LlSsaZOEFz5iMavMcvvV37Mr6mN8kv51Xdl7cXUCYIr39VcuaTrSsoaZW1d
rqz9ffE6wZUFmisduXPl7PuvzRNc2aTxa8jye+0O5tf8GeWX8qvvStdcYn5tV7pDmivNuq6k
rFHWiK40YtYyN/69zwh/rTxVzYAL9kQGwvFA7CgfjUUGg/6Anz90nPen/xDKIpPhuXcLzlVy
mf7zaJ0B9c9kuDXinzbvKTjjb+/tSlmIKgAA
--------------D93A920BA017053A8998C73A--
