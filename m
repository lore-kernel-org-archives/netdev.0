From: James Ketrenos <jketreno@linux.intel.com>
Subject: [RFC] d80211 naming convention
Date: Wed, 08 Nov 2006 14:06:18 -0800
Message-ID: <455254DA.1090607@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020202010208040809020908"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:64160 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S965722AbWKHV7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 16:59:54 -0500
To: NetDev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020202010208040809020908
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


The discussion on another thread about ieee80211_local brought to mind a
discussion from a while ago about shortening the prefix 'ieee80211' used
in structures, defines, variables, function names, etc.

Are people still interested in changing that name to something else?
Would switching from using the ieee prefix to just d work? (d80211 vs.
ieee80211)?  Or perhaps dropping all the way to dot11 (save 4 characters)?

I put together the script convert-to-d80211.sh to switch everything
in-tree from using d80211's ieee80211 prefix to use d80211.  The script,
when run, results in a 22.8kl patch changing 61 files.

Switching to dot11 can be achieved by running convert-to-d80211.sh and
then running convert-to-dot11.sh.  The cumulative patch size by running
the two scripts is 24.3kl changing 78 files.

The scripts assume you have git/cogito installed (they cg-rm and cg-add
to migrate the files to use the new names)  Cogito complains about files
not existing when being removed since they have already been moved on
disk to the dot11 directories.

Git catches the file/directory renames and retains the history the files
moving.

I ran the scripts and performed a test build against the wireless
subsystem and all wireless drivers and all continued to build.  I
haven't done any run-time testing.

Anyway, if no one ever wants to change the names, no biggie.  If it is
something people are thinking about maybe doing, the scripts should make
that change trivial.

Personally I prefer the way things lay out after running both scripts;
its nice to have more of the 80 column width for things other than the
subsystem prefix :)  Its also nice having the subsystem name match the
prefix used.

James


--------------020202010208040809020908
Content-Type: application/x-shellscript;
 name="convert-to-d80211.sh"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="convert-to-d80211.sh"

IyEvYmluL2Jhc2gKIwojIFJ1biBmcm9tIHRoZSByb290IG9mIHlvdXIga2VybmVsIHNvdXJj
ZXMKIwpjZCBpbmNsdWRlL25ldApzZWQgLWkgLWUgInM6aWVlZTgwMjExOmQ4MDIxMTpnIiAt
ZSAiczpJRUVFODAyMTE6RDgwMjExOmciIGQ4MDIxMSouaApjZCAuLi8uLgoKY2QgbmV0L2Q4
MDIxMQpzZWQgLWkgLWUgInM6aWVlZTgwMjExOmQ4MDIxMTpnIiBcCgktZSAiczpJRUVFODAy
MTE6RDgwMjExOmciIFwKCS1lICJzOkFSUEhSRF9EODAyMTE6QVJQSFJEX0lFRUU4MDIxMTpn
IiBcCgkqLntjLGh9IEtjb25maWcgTWFrZWZpbGUKZm9yIHNyYyBpbiAqaWVlZTgwMjExKi57
YyxofTsgZG8KCVsgISAtZSAkc3JjIF0gJiYgY29udGludWUKCWRzdD0ke3NyYy9pZWVlODAy
MTEvZDgwMjExfQoJY2ctcm0gJHNyYwoJbXYgJHNyYyAkZHN0CgljZy1hZGQgJGRzdApkb25l
CmNkIC4uLy4uCgpzZWQgLWkgLWUgInM6aWVlZTgwMjExX3B0cjpkODAyMTFfcHRyOmciIFwK
CWluY2x1ZGUvbGludXgvbmV0ZGV2aWNlLmgKCmZpbmQgZHJpdmVycy9uZXQvd2lyZWxlc3Mv
ZDgwMjExIC10eXBlIGYgfCB3aGlsZSByZWFkIGZpbGU7IGRvCglzZWQgLWkgLWUgInM6aWVl
ZTgwMjExOmQ4MDIxMTpnIiAtZSAiczpJRUVFODAyMTE6RDgwMjExOmciICRmaWxlCmRvbmUK
Cg==
--------------020202010208040809020908
Content-Type: application/x-shellscript;
 name="convert-to-dot11.sh"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="convert-to-dot11.sh"

IyEvYmluL2Jhc2gKIwojIFJ1biBmcm9tIHRoZSByb290IG9mIHlvdXIga2VybmVsIHNvdXJj
ZXMKIwoKZWNobyAiTWlncmF0aW5nIGQ4MDIxMSBzdGFjayB0byBkb3QxMSIKbXYgbmV0L2Q4
MDIxMSBuZXQvZG90MTEKY2QgbmV0L2RvdDExCnNlZCAtaSAtZSAiczpkODAyMTE6ZG90MTE6
ZyIgXAoJLWUgInM6RDgwMjExOkRPVDExOmciIFwKCSoue2MsaH0gS2NvbmZpZyBNYWtlZmls
ZQpmb3Igc3JjIGluICpkODAyMTEqLntjLGh9OyBkbwoJWyAhIC1lICRzcmMgXSAmJiBjb250
aW51ZQoJZHN0PSR7c3JjL2Q4MDIxMS9kb3QxMX0KCW12ICRzcmMgJGRzdApkb25lCmNkIC4u
Ly4uCgpjZy1hZGQgLXIgbmV0L2RvdDExCmNnLXJtIC1hIG5ldC9kODAyMTEKCgplY2hvICJG
aXhpbmcgdXAga2VybmVsIGJ1aWxkLCBpbmNsdWRlcywgYW5kIG5ldGRldmljZSIKc2VkIC1p
IC1lICJzOmQ4MDIxMTpkb3QxMTpnIiBuZXQve0tjb25maWcsTWFrZWZpbGV9CgpzZWQgLWkg
LWUgInM6ZDgwMjExX3B0cjpkb3QxMV9wdHI6ZyIgXAoJaW5jbHVkZS9saW51eC9uZXRkZXZp
Y2UuaAoKY2QgaW5jbHVkZS9uZXQKc2VkIC1pIC1lICJzOmQ4MDIxMTpkb3QxMTpnIiAtZSAi
czpEODAyMTE6RE9UMTE6ZyIgZDgwMjExKi5oCmZvciBzcmMgaW4gKmQ4MDIxMSouaDsgZG8K
CVsgISAtZSAkc3JjIF0gJiYgY29udGludWUKCWRzdD0ke3NyYy9kODAyMTEvZG90MTF9Cglt
diAkc3JjICRkc3QKCWNnLWFkZCAkZHN0CmRvbmUKY2QgLi4vLi4KY2ctcm0gLWEgaW5jbHVk
ZS9uZXQvCgoKZWNobyAiTWlncmF0aW5nIGQ4MDIxMSBkcml2ZXJzIHRvIHVzZSBkb3QxMSIK
CnNlZCAtaSAtZSAiczpkODAyMTE6ZG90MTE6ZyIgZHJpdmVycy9uZXQvd2lyZWxlc3Mve0tj
b25maWcsTWFrZWZpbGV9CgptdiBkcml2ZXJzL25ldC93aXJlbGVzcy9kODAyMTEgZHJpdmVy
cy9uZXQvd2lyZWxlc3MvZG90MTEKZmluZCBkcml2ZXJzL25ldC93aXJlbGVzcy9kb3QxMSAt
dHlwZSBmIHwgd2hpbGUgcmVhZCBmaWxlOyBkbwoJc2VkIC1pIC1lICJzOmQ4MDIxMTpkb3Qx
MTpnIiAtZSAiczpEODAyMTE6RE9UMTE6ZyIgJGZpbGUKZG9uZQoKY2ctYWRkIC1yIGRyaXZl
cnMvbmV0L3dpcmVsZXNzL2RvdDExCmNnLXJtIC1hIGRyaXZlcnMvbmV0L3dpcmVsZXNzL2Q4
MDIxMQoK
--------------020202010208040809020908--
