From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-bk+ broken networking
Date: Wed, 4 Jun 2003 20:26:22 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030604202622.1be40092.akpm@digeo.com>
References: <20030604161437.2b4d3a79.shemminger@osdl.org>
	<3EDE7FEB.2C7FAEC7@digeo.com>
	<20030604185652.31958d1f.akpm@digeo.com>
	<20030605023349.GH24515@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, davem@redhat.com,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030605023349.GH24515@conectiva.com.br>
List-Id: netdev.vger.kernel.org

broken "cleanup"

 net/core/iovec.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff -puN net/core/iovec.c~iovec-fix net/core/iovec.c
--- 25/net/core/iovec.c~iovec-fix	2003-06-04 20:23:03.000000000 -0700
+++ 25-akpm/net/core/iovec.c	2003-06-04 20:24:05.000000000 -0700
@@ -47,9 +47,10 @@ int verify_iovec(struct msghdr *m, struc
 						  address);
 			if (err < 0)
 				return err;
-			m->msg_name = address;
-		} else
-			m->msg_name = NULL;
+		}
+		m->msg_name = address;
+	} else {
+		m->msg_name = NULL;
 	}
 
 	size = m->msg_iovlen * sizeof(struct iovec);

_
