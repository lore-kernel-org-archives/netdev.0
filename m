From: Matej Kupljen <matej.kupljen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: HSO driver patch [1/2]
Date: Fri, 7 Oct 2016 16:29:42 +0200
Message-ID: <CAHMF36FfubzNOcaud613oVuM4YZoC_y29GtMC_h7HDNLOSm8Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114cb4c4c80a1d053e473d35
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--001a114cb4c4c80a1d053e473d35
Content-Type: text/plain; charset=UTF-8

Hi,


I am using hso driver for my 3G modem (although different manufacturer
with different USB VID/PID) but I have some problems with it. It is
working fine, but if you disconnect the USB connection while the data
is transferring trough AT interface, we get a crash.

There are two patches:
 1.) 0001-Reverse-the-order-in-disconnect.patch
      This patch first sets the interface to NULL and only then starts
removing the allocated
      resources. This is according to documentation and it is also
more similar to other drivers.
 2.) 0002-Stop-also-serial-queue-when-device-is-unplugged.patch
      Serial device was not stopped when the device got unplugged so
there are continues error
      messages that the URB cannot be submitted.

Another problem is that we can hit the WARN macro in hso_serial_open by:
1.) Plug in the USB modem
2.) Load hso.ko module
3.) Create the /dev nodes
4.) do a less -f /dev/ttyHS2
5.) unplug the USB modem
6.) Re-plug it and back
7.) Quit previous less by pressing q
8.) start less again like in 4 and you'll get

[  198.828136] ------------[ cut here ]------------
[  198.832788] WARNING: CPU: 2 PID: 1799 at include/linux/kref.h:47
kobject_get+0x9c/0xa8()
[  198.840886] Modules linked in: hso
[  198.844337] CPU: 2 PID: 1799 Comm: less Not tainted
4.1.13-00130-g126c250-dirty #5
[  198.851917] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
[  198.858481] [<80017b70>] (unwind_backtrace) from [<800137d0>]
(show_stack+0x10/0x14)
[  198.866246] [<800137d0>] (show_stack) from [<8063caa0>]
(dump_stack+0x84/0xc4)
[  198.873492] [<8063caa0>] (dump_stack) from [<8002857c>]
(warn_slowpath_common+0x84/0xb4)
[  198.881597] [<8002857c>] (warn_slowpath_common) from [<80028648>]
(warn_slowpath_null+0x1c/0x24)
[  198.890398] [<80028648>] (warn_slowpath_null) from [<802533a8>]
(kobject_get+0x9c/0xa8)
[  198.898420] [<802533a8>] (kobject_get) from [<80110b90>] (cdev_get+0x2c/0x4c)
[  198.905571] [<80110b90>] (cdev_get) from [<80110eb0>]
(chrdev_open+0x2c/0x178)
[  198.912812] [<80110eb0>] (chrdev_open) from [<8010aff0>]
(do_dentry_open+0x1d8/0x2f8)
[  198.920666] [<8010aff0>] (do_dentry_open) from [<80118958>]
(do_last+0x564/0xce4)
[  198.928164] [<80118958>] (do_last) from [<8011b0fc>] (path_openat+0x80/0x5cc)
[  198.935330] [<8011b0fc>] (path_openat) from [<8011c0f8>]
(do_filp_open+0x2c/0x88)
[  198.942832] [<8011c0f8>] (do_filp_open) from [<8010c36c>]
(do_sys_open+0x108/0x1cc)
[  198.950508] [<8010c36c>] (do_sys_open) from [<80010140>]
(ret_fast_syscall+0x0/0x60)
[  198.958292] ---[ end trace d0b32f14e1047616 ]---

Thanks,
Matej

--001a114cb4c4c80a1d053e473d35
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-Reverse-the-order-in-disconnect.patch"
Content-Disposition: attachment;
	filename="0001-Reverse-the-order-in-disconnect.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_itzvbqe50

RnJvbSBmNTYwYjEyN2NhOWJiN2M1MjEwNmYwZjgzMDkxZTZjNWUwZTkwYjA5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNYXRlaiBLdXBsamVuIDxtYXRlai5rdXBsamVuQG5vcmlrLnNp
PgpEYXRlOiBXZWQsIDI4IFNlcCAyMDE2IDE4OjM3OjIzICswMjAwClN1YmplY3Q6IFtQQVRDSF0g
UmV2ZXJzZSB0aGUgb3JkZXIgaW4gZGlzY29ubmVjdAoKV2hlbiB0aGUgZGV2aWNlIGlzIGRpc2Nv
bm5lY3RlZCwgd2UgZmlyc3QgbmVlZCB0byBzZXQgaW50ZXJmYWNlCmRhdGEgdG8gTlVMTCBhbmQg
dGhlbiBkbyB0aGUgZnJlZWluZyBvZiByZXNvdXJjZXMgdG8gYXZvaWQgcmFjZQpjb25kaXRpb25z
LgoKU2lnbmVkLW9mZi1ieTogTWF0ZWogS3VwbGplbiA8bWF0ZWoua3VwbGplbkBub3Jpay5zaT4K
LS0tCiBkcml2ZXJzL25ldC91c2IvaHNvLmMgfCA0ICsrLS0KIDEgZmlsZSBjaGFuZ2VkLCAyIGlu
c2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvdXNi
L2hzby5jIGIvZHJpdmVycy9uZXQvdXNiL2hzby5jCmluZGV4IGIwZGY2MWYuLjE2YWVmMDYgMTAw
NjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3VzYi9oc28uYworKysgYi9kcml2ZXJzL25ldC91c2IvaHNv
LmMKQEAgLTMwMTMsMTAgKzMwMTMsMTAgQEAgZXhpdDoKIC8qIGRldmljZSByZW1vdmVkLCBjbGVh
bmluZyB1cCAqLwogc3RhdGljIHZvaWQgaHNvX2Rpc2Nvbm5lY3Qoc3RydWN0IHVzYl9pbnRlcmZh
Y2UgKmludGVyZmFjZSkKIHsKLQloc29fZnJlZV9pbnRlcmZhY2UoaW50ZXJmYWNlKTsKLQogCS8q
IHJlbW92ZSByZWZlcmVuY2Ugb2Ygb3VyIHByaXZhdGUgZGF0YSAqLwogCXVzYl9zZXRfaW50ZmRh
dGEoaW50ZXJmYWNlLCBOVUxMKTsKKworCWhzb19mcmVlX2ludGVyZmFjZShpbnRlcmZhY2UpOwog
fQogCiBzdGF0aWMgdm9pZCBhc3luY19nZXRfaW50ZihzdHJ1Y3Qgd29ya19zdHJ1Y3QgKmRhdGEp
Ci0tIAoyLjcuNAoK
--001a114cb4c4c80a1d053e473d35--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
