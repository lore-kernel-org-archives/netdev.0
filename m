From: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Subject: Re: tun offloads bug
Date: Thu, 16 Mar 2017 21:23:51 +0300
Message-ID: <CADS+iDXrkp6vrj9dAYQqnGPm+-RYizYz_iEW0LEkqdXsxBfV2Q@mail.gmail.com>
References: <CADS+iDW49e+oSw9p_MBOVk4Qojh+e00a5zix-sO8NQethn=pjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11441e58ef3edf054add2af5
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36679 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753650AbdCPSYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:24:14 -0400
Received: by mail-wm0-f53.google.com with SMTP id n11so119054857wma.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:24:13 -0700 (PDT)
In-Reply-To: <CADS+iDW49e+oSw9p_MBOVk4Qojh+e00a5zix-sO8NQethn=pjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11441e58ef3edf054add2af5
Content-Type: text/plain; charset=UTF-8

Hello! I'm sending new patch, with proper formatting and signed tag

2017-03-08 23:29 GMT+03:00 Yaroslav Isakov <yaroslav.isakov@gmail.com>:
> Hello!
> I've found a bug in TUN/TAP driver with offloads - when Qemu is trying
> to set offloads on tap device, there is no error, but offloads are not
> appied.
>
> The cause of this is that udev in recent systemd is using ethtool to
> disable offloads. So, udev is setting tun->dev->wanted_features via
> ethtool ioctl to disable TSO, but when qemu is trying to set offloads,
> it's using TUN/TAP ioctl which is not setting wanted_features, so
> netdev_update_features will not see features qemu wants.
>
> This can be easily reproduced - just run qemu with
> guest_tso4=on,guest_tso6=on on systemd with systemd>=226 and after
> booting the VM, ethtool -k tap0 will show that TSO4 is disabled and
> TSO6 is enabled (systemd is not touching TSO6, that's why it's not
> affected at all)
> I've attached pretty trivial patch to fix this problem.

--001a11441e58ef3edf054add2af5
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-tun-fix-inability-to-set-offloads-after-disabling-th.patch"
Content-Disposition: attachment;
	filename="0001-tun-fix-inability-to-set-offloads-after-disabling-th.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j0cq4iox1

RnJvbSAxMmE1MDc5ZWY2MTcyYzMyYWMxOWI2MDYzMTBkYjE1MWM3Y2EzZTVkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZYXJvc2xhdiBJc2Frb3YgPHlhcm9zbGF2LmlzYWtvdkBnbWFp
bC5jb20+CkRhdGU6IFRodSwgMTYgTWFyIDIwMTcgMjE6MDg6MzcgKzAzMDAKU3ViamVjdDogW1BB
VENIXSB0dW46IGZpeCBpbmFiaWxpdHkgdG8gc2V0IG9mZmxvYWRzIGFmdGVyIGRpc2FibGluZyB0
aGVtIHZpYQogZXRodG9vbAoKRnJvbTogWWFyb3NsYXYgSXNha292IDx5YXJvc2xhdi5pc2Frb3ZA
Z21haWwuY29tPgoKQWRkZWQgbWlzc2luZyBsb2dpYyBpbiB0dW4gZHJpdmVyLCB3aGljaCBwcmV2
ZW50cyBhcHBzIHRvIHNldApvZmZsb2FkcyB1c2luZyB0dW4gaW9jdGwsIGlmIG9mZmxvYWRzIHdl
cmUgcHJldmlvdXNseSBkaXNhYmxlZCB2aWEgZXRodG9vbAoKU2lnbmVkLW9mZi1ieTogWWFyb3Ns
YXYgSXNha292IDx5YXJvc2xhdi5pc2Frb3ZAZ21haWwuY29tPgotLS0KIGRyaXZlcnMvbmV0L3R1
bi5jIHwgMiArKwogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBh
L2RyaXZlcnMvbmV0L3R1bi5jIGIvZHJpdmVycy9uZXQvdHVuLmMKaW5kZXggMzRjYzNjNS4uY2M4
OGNkNyAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvdHVuLmMKKysrIGIvZHJpdmVycy9uZXQvdHVu
LmMKQEAgLTE5MzEsNiArMTkzMSw4IEBAIHN0YXRpYyBpbnQgc2V0X29mZmxvYWQoc3RydWN0IHR1
bl9zdHJ1Y3QgKnR1biwgdW5zaWduZWQgbG9uZyBhcmcpCiAJCXJldHVybiAtRUlOVkFMOwogCiAJ
dHVuLT5zZXRfZmVhdHVyZXMgPSBmZWF0dXJlczsKKwl0dW4tPmRldi0+d2FudGVkX2ZlYXR1cmVz
ICY9IH5UVU5fVVNFUl9GRUFUVVJFUzsKKwl0dW4tPmRldi0+d2FudGVkX2ZlYXR1cmVzIHw9IGZl
YXR1cmVzOwogCW5ldGRldl91cGRhdGVfZmVhdHVyZXModHVuLT5kZXYpOwogCiAJcmV0dXJuIDA7
Ci0tIAoyLjEwLjIKCg==
--001a11441e58ef3edf054add2af5--
