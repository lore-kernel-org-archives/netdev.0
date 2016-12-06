From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH]net:witchdev:release the lock before function return to
 avoid dead lock
Date: Tue, 6 Dec 2016 09:06:55 +0100
Message-ID: <20161206080655.GC1984@nanopsycho>
References: <CAEX1niVLkt=LQhjrALsUrN+oEa9ZEUJ7X+tbNFs71RLm6ryZCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, feng.deng@cortina-access.com
To: Feng Deng <cxdx2006@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAEX1niVLkt=LQhjrALsUrN+oEa9ZEUJ7X+tbNFs71RLm6ryZCA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Dec 06, 2016 at 03:58:29AM CET, cxdx2006@gmail.com wrote:
>From : Feng Deng <cxdx2006@gmail.com>
>
>In switchdev_deferred_dequeue(),only get the lock at the beginning,
>but forgot to release before return,
>we must release the lock to avoid dead lock
 
Feng, your patches are corrupted. Please use "git send-email"
Also, when you send a fit for -net tree, you have to pass byt the
"Fixes" tag. Please see the git log for details.

Thanks!


>
>Signed-off-by: Feng Deng <feng.deng@cortina-access.com>
>---
> net/switchdev/switchdev.c | 1 +
> 1 file changed, 1 insertion(+)
> mode change 100644 => 100755 net/switchdev/switchdev.c
>
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 3b95fe9..c0a1ad4
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -120,6 +120,7 @@ static struct switchdev_deferred_item
>*switchdev_deferred_dequeue(void)
>  dfitem = list_first_entry(&deferred,
>   struct switchdev_deferred_item, list);
>  list_del(&dfitem->list);
>+ spin_unlock_bh(&deferred_lock);
> unlock:
>  spin_unlock_bh(&deferred_lock);
>  return dfitem;
>-- 
>1.8.3.1
