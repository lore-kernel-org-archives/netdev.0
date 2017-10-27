From: David Ahern <dsahern@gmail.com>
Subject: breakage due to commit 6e617de84e ("net: avoid a full fib lookup when
 rp_filter is disabled")
Date: Thu, 26 Oct 2017 21:50:37 -0600
Message-ID: <248fe046-1f13-1a9e-b587-e16515395be5@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------84DF42BA23B47B35F2735658"
To: Paolo Abeni <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:43981 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdJ0Duk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 23:50:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id a8so4026049pfc.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 20:50:40 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------84DF42BA23B47B35F2735658
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi Paolo:

Your commit:

commit 6e617de84e87d626d1e976fc30e1322239fd4d2d
Author: Paolo Abeni <pabeni@redhat.com>
Date:   Wed Sep 20 18:26:53 2017 +0200

    net: avoid a full fib lookup when rp_filter is disabled.

breaks a test case that uses a veth pair in the same network namespace
but separate VRFs. This setup:

vrf add vrf0 table 1001
vrf add vrf1 table 1002

ip link add virt01 type veth peer name virt10
ip link set virt01 master vrf0
ip link set virt10 master vrf1

ip addr add 172.16.20.20/24 dev virt01
ip link set virt01 up

ip addr add 172.16.20.21/24 dev virt10
ip link set virt10 up

ping -c 1 -I vrf0 172.16.20.21

fails due to:

    if (inet_lookup_ifaddr_rcu(net, src))
       return -EINVAL;

in fib_validate_source.

David

--------------84DF42BA23B47B35F2735658
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="mpls-vrf-cmds"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="mpls-vrf-cmds"

IyEvYmluL3NoCgojIHZyZjAgc2VuZHMgb3V0IHBhY2tldHMgd2l0aCBtcGxzIGxhYmVscwoj
IHZyZjEgcmVjZWl2ZXMgdGhlIGxhYmVsbGVkIHBhY2tldHMsIHBvcHMgdGhlIGxhYmVscywg
YW5kIGZvcndhcmRzIHRvIHZyZjIKIyB2cmYyIHJlY2VpdmVzIHRoZSB1bmxhYmVsbGVkIHBh
Y2tldHMgYW5kIHJlcGxpZXMgdG8gdnJmMAoKdnJmIGFkZCB2cmYwIHRhYmxlIDEwMDEKdnJm
IGFkZCB2cmYxIHRhYmxlIDEwMDIKdnJmIGFkZCB2cmYyIHRhYmxlIDEwMDMKCmlwIGxpbmsg
YWRkIHZpcnQwMSB0eXBlIHZldGggcGVlciBuYW1lIHZpcnQxMAppcCBsaW5rIHNldCB2aXJ0
MDEgbWFzdGVyIHZyZjAKaXAgbGluayBzZXQgdmlydDEwIG1hc3RlciB2cmYxCgppcCBsaW5r
IGFkZCB2aXJ0MTIgdHlwZSB2ZXRoIHBlZXIgbmFtZSB2aXJ0MjEKaXAgbGluayBzZXQgdmly
dDEyIG1hc3RlciB2cmYxCmlwIGxpbmsgc2V0IHZpcnQyMSBtYXN0ZXIgdnJmMgoKaXAgYWRk
ciBhZGQgMTcyLjE2LjIwLjIwLzI0IGRldiB2aXJ0MDEKaXAgbGluayBzZXQgdmlydDAxIHVw
CgppcCBhZGRyIGFkZCAxNzIuMTYuMjAuMjEvMjQgZGV2IHZpcnQxMAppcCBsaW5rIHNldCB2
aXJ0MTAgdXAKaXAgYWRkciBhZGQgMTcyLjE2LjIxLjIxLzI0IGRldiB2aXJ0MTIKaXAgbGlu
ayBzZXQgdmlydDEyIHVwCgppcCBhZGRyIGFkZCAxNzIuMTYuMjEuMjIvMjQgZGV2IHZpcnQy
MQppcCBsaW5rIHNldCB2aXJ0MjEgdXAKCm1vZHByb2JlIG1wbHNfaXB0dW5uZWwKCmlwIHJv
dXRlIGFkZCB2cmYgdnJmMCAxMC4xMC4xMC4xMC8zMiBlbmNhcCBtcGxzIDEwMCB2aWEgaW5l
dCAxNzIuMTYuMjAuMjEgCmlwIHJvdXRlIGFkZCB2cmYgdnJmMCAxNzIuMTYuMjEuMC8yNCB2
aWEgMTcyLjE2LjIwLjIxIAoKc3lzY3RsIC13IG5ldC5tcGxzLmNvbmYudmlydDEwLmlucHV0
PTEKc3lzY3RsIC13IG5ldC5tcGxzLnBsYXRmb3JtX2xhYmVscz0xMDAwCmlwIC1mIG1wbHMg
cm91dGUgYWRkIDEwMCB2aWEgaW5ldCAxNzIuMTYuMjEuMjIgZGV2IHZpcnQxMgoKaXAgYWRk
ciBhZGQgMTAuMTAuMTAuMTAvMzIgZGV2IHZyZjIKaXAgcm91dGUgYWRkIHZyZiB2cmYyIDE3
Mi4xNi4yMC4wLzI0IHZpYSAxNzIuMTYuMjEuMjEKCnBpbmcgLWMgMSAtSSB2cmYwIDEwLjEw
LjEwLjEwCgpuZXRzZXJ2ZXIKCmNhdCA8PEVPRgojIG5vbi1tcGxzCm5ldHBlcmYgLUogdnJm
MCAtYyAtQyAtSCAxNzIuMTYuMjEuMjIgLWwgMTAgLXQgVENQX1NUUkVBTQoKIyBtcGxzIChy
ZXRyeSB0aGlzIHdpdGggbXBsc19nc28gbG9hZGVkKQpuZXRwZXJmIC1KIHZyZjAgLWMgLUMg
LUggMTAuMTAuMTAuMTAgLWwgMTAgLXQgVENQX1NUUkVBTQpFT0YK
--------------84DF42BA23B47B35F2735658--
