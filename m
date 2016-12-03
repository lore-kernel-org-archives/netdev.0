From: Pan Bian <bianpan201602@163.com>
Subject: Re: [PATCH 1/1] net: caif: fix ineffective error check
Date: Sat,  3 Dec 2016 23:38:56 +0800
Message-ID: <20161203153535.GA7976@bp>
References: <1480763901-5323-1-git-send-email-bianpan2016@163.com> <f214a441-9e4b-6c40-f09d-32a6d1ea4dd0@cogentembedded.com>
Reply-To: PanBian <bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: PanBian <bianpan2016@163.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f214a441-9e4b-6c40-f09d-32a6d1ea4dd0@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: PanBian <bianpan2016@163.com>

Hello Sergei,

On Sat, Dec 03, 2016 at 04:17:51PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/3/2016 2:18 PM, Pan Bian wrote:
> 
> >In function caif_sktinit_module(), the check of the return value of
> >sock_register() seems ineffective. This patch fixes it.
> >
> >Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188751
> >
> >Signed-off-by: Pan Bian <bianpan2016@163.com>
> >---
> > net/caif/caif_socket.c | 2 +-
> > 1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
> >index aa209b1..2a689a3 100644
> >--- a/net/caif/caif_socket.c
> >+++ b/net/caif/caif_socket.c
> >@@ -1108,7 +1108,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
> > static int __init caif_sktinit_module(void)
> > {
> > 	int err = sock_register(&caif_family_ops);
> >-	if (!err)
> >+	if (err)
> > 		return err;
> 
>    Why not just:
> 
> 	return sock_register(&caif_family_ops);
>
	Your solution looks much cleaner.

	But I am not really sure whether it is the author's intention to
	return 0 anyway. Do you have any idea?

	Thanks!
> > 	return 0;
> > }
> 
> MBR, Sergei
> 

Best regards,
Pan
