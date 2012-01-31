From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] sysfs:  Update the name hash when renaming sysfs entries
Date: Tue, 31 Jan 2012 06:40:26 -0800
Message-ID: <m1zkd45411.fsf_-_@fess.ebiederm.org>
References: <4F27120A.4040106@suse.cz>
	<CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
	<4F27C54F.1010107@suse.cz>
	<CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
	<4F27C9D4.3040105@suse.cz>
	<CAPXgP12pj6esZVmN-PYTVgJ+_MaAfmpa9hKoKKQZ+Y=Y-Kb4eA@mail.gmail.com>
	<4F27CDBC.5020201@suse.cz>
	<CAPXgP1371fgmaP3ecxsDJ2BmJrOS6kUP95G1BHe6deBPk5FVCQ@mail.gmail.com>
	<m18vko6jmv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Greg KH <greg@kroah.com>, Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m18vko6jmv.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Tue, 31 Jan 2012 06:18:00 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This fixes a bug introduced with sysfs name hashes where renaming a
network device appears to succeed but silently makes the sysfs files for
that network device inaccessible.

In at least one configuration this bug has stopped networking from
coming up during boot.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/dir.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index ea64d01..dd3779c 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -872,6 +872,7 @@ int sysfs_rename(struct sysfs_dirent *sd,
 
 		dup_name = sd->s_name;
 		sd->s_name = new_name;
+		sd->s_hash = sysfs_name_hash(sd->s_ns, sd->s_name);
 	}
 
 	/* Move to the appropriate place in the appropriate directories rbtree. */
-- 
1.7.2.5
