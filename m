From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] wireless: Remove casts of void *
Date: Mon, 13 Jun 2011 22:32:12 -0700
Message-ID: <1308029532.26699.68.camel@Joe-Laptop>
References: <cover.1308024069.git.joe@perches.com>
	 <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
	 <BANLkTi=i30Rn7gpCDbn9KKJucq8CB=hssA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=i30Rn7gpCDbn9KKJucq8CB=hssA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-06-14 at 15:23 +1000, Julian Calaby wrote:
> Joe,

Hi Julian.

> On Tue, Jun 14, 2011 at 14:02, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > Unnecessary casts of void * clutter the code.
> > These are the remainder casts after several specific
> > patches to remove netdev_priv and dev_priv.
> You seem to have removed a lot of casts that don't relate to these cleanups.
> In particular, some of the casts seem to relate more to documentation
> rather than just changing pointer types to make the compiler happy.

All of the cast removals are casts of void* types.
I think none of of the casts are useful.
None of them are required, all are duplicative.

> In
> particular, I'm referring to the casts describing the different usages
> of data_buf in mwiflex, and around some pointer math in ath9k.

Can you describe more in detail why you think these are documentary?

This sort of cast:

diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
@@ -191,7 +191,7 @@ int mwifiex_ret_11n_cfg(struct host_cmd_ds_command *resp, void *data_buf)
 	struct host_cmd_ds_11n_cfg *htcfg = &resp->params.htcfg;
 
 	if (data_buf) {
-		tx_cfg = (struct mwifiex_ds_11n_tx_cfg *) data_buf;
+               tx_cfg = data_buf;

I think pretty useless.  tx_cfg is a struct mwifiex_ds_11n_tx_cfg *.

> Whilst I'm sure that the compiler is smart enough to handle automatic
> casts between pointer types, some of these, in particular the mwiflex
> bits, add some documentation to the code.

I think not.  Opinions of course can vary.

cheers, Joe

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
