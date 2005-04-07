From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for routing rules
Date: Fri, 8 Apr 2005 00:38:47 +0200
Message-ID: <20050407223847.GX26731@postel.suug.ch>
References: <20050407213838.GW26731@postel.suug.ch> <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au> 2005-04-08 08:09
> Thomas Graf <tgraf@suug.ch> wrote:
> >
> > diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> > --- a/net/core/rtnetlink.c      2005-04-07 23:13:33 +02:00
> > +++ b/net/core/rtnetlink.c      2005-04-07 23:13:33 +02:00
> > @@ -647,7 +647,8 @@
> >        [RTM_GETROUTE - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
> >        [RTM_NEWNEIGH - RTM_BASE] = { .doit   = neigh_add             },
> >        [RTM_DELNEIGH - RTM_BASE] = { .doit   = neigh_delete          },
> > -       [RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info       }
> > +       [RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info       },
> > +       [RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    }
> > };
> 
> Just a trivial comment.  How about adding a comma at the end of the last
> entry so that the next patch won't have to touch it?

Sure, bk fix'ed and new patch attached. However, I haven't read all
the recent happenings around bk and somewhat missed rc2. I just noticed
the freeze so not sure if this still makes sense.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/08 00:24:50+02:00 tgraf@suug.ch 
#   [RTNETLINK]: Protocol family wildcard dumping for routing rules
#   
#   Be kind to userspace and don't force them to hardcode protocol
#   families just to have it changed again once we support routing
#   rules for more than one protocol family.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/rtnetlink.c
#   2005/04/08 00:24:40+02:00 tgraf@suug.ch +2 -1
#   [RTNETLINK]: Protocol family wildcard dumping for routing rules
# 
diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	2005-04-08 00:35:37 +02:00
+++ b/net/core/rtnetlink.c	2005-04-08 00:35:37 +02:00
@@ -647,7 +647,8 @@
 	[RTM_GETROUTE - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
 	[RTM_NEWNEIGH - RTM_BASE] = { .doit   = neigh_add	      },
 	[RTM_DELNEIGH - RTM_BASE] = { .doit   = neigh_delete	      },
-	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      }
+	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      },
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
 };
 
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)
