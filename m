From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [NETNS] change net/Kconfig to avoid a broken build when building with network namesapce support.
Date: Tue, 29 Jan 2008 12:53:02 +0200
Message-ID: <eb3ff54b0801290253g657590acoc420eb7c6fcaa7c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4273_10387102.1201603983007"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:7493 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbYA2KxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 05:53:04 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2048223fga.17
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 02:53:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_4273_10387102.1201603983007
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

The build is broken with the following kernel configuration:

- net-2.6.25
- Support for network namespaces enabled (CONFIG_NET_NS=y)
- CONFIG_RCU_TRACE=y
	CONFIG_RCU_TRACE can be set by:
	 make menuconfig ->Processor type and features->Enable tracing for RCU.
	
- The error in build is :
	  fs/built-in.o: In function `debugfs_init':
	 /work/src/netGit2.6.25/2.6.25/fs/debugfs/inode.c:435: undefined
	 reference to `kernel_kobj'
	 make: *** [.tmp_vmlinux1] Error 1

The reason is : RCU_TRACE selects DEBUG_FS,
 but CONFIG_NET_NS depends on EXPERIMENTAL && !SYSFS;
 debugfs can't be built without sysfs.

 There is currently a bit of mess with SYSFS and in fact it seems that
maybe selecting DEBUG_FS
should depend on SYSFS; to avoid this problem in the build,
 this patch adds !DEBUG_FS to CONFIG_NET_NS dependencies in net/Kconfig.
 This way, if CONFIG_RCU_TRACE is set, ( or other configuration items which
selects DEBUG_FS), we cannot set CONFIG_NET_NS.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_4273_10387102.1201603983007
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fc0bs1ok0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9LY29uZmlnIGIvbmV0L0tjb25maWcKaW5kZXggYjZhNWQ0NS4uODIz
MzdlMiAxMDA2NDQKLS0tIGEvbmV0L0tjb25maWcKKysrIGIvbmV0L0tjb25maWcKQEAgLTMwLDcg
KzMwLDcgQEAgbWVudSAiTmV0d29ya2luZyBvcHRpb25zIgogY29uZmlnIE5FVF9OUwogCWJvb2wg
Ik5ldHdvcmsgbmFtZXNwYWNlIHN1cHBvcnQiCiAJZGVmYXVsdCBuCi0JZGVwZW5kcyBvbiBFWFBF
UklNRU5UQUwgJiYgIVNZU0ZTCisJZGVwZW5kcyBvbiBFWFBFUklNRU5UQUwgJiYgIVNZU0ZTICYm
ICFERUJVR19GUwogCWhlbHAKIAkgIEFsbG93IHVzZXIgc3BhY2UgdG8gY3JlYXRlIHdoYXQgYXBw
ZWFyIHRvIGJlIG11bHRpcGxlIGluc3RhbmNlcwogCSAgb2YgdGhlIG5ldHdvcmsgc3RhY2suCg==

------=_Part_4273_10387102.1201603983007--
