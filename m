From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number next.
Date: Tue, 26 Apr 2005 13:20:08 -0500
Message-ID: <d120d50005042611203ce29dd8@mail.gmail.com>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	 <d120d5000504260857cb5f99e@mail.gmail.com>
	 <20050426202437.234e7d45@zanzibar.2ka.mipt.ru>
	 <20050426203023.378e4831@zanzibar.2ka.mipt.ru>
	 <d120d50005042610342368cd72@mail.gmail.com>
	 <20050426220713.7915e036@zanzibar.2ka.mipt.ru>
Reply-To: dtor_core@ameritech.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
        Jamal Hadi Salim <hadi@cyberus.ca>, Kay Sievers <kay.sievers@vrfy.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        James Morris <jmorris@redhat.com>,
        Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
        linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
        Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20050426220713.7915e036@zanzibar.2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4/26/05, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Yes, I found it too.
> Following patch should be the solution:
> 
> --- orig/drivers/connector/connector.c
> +++ mod/drivers/connector/connector.c
> @@ -146,13 +146,16 @@
>        spin_lock_bh(&dev->cbdev->queue_lock);
>        list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
>                if (cn_cb_equal(&__cbq->cb->id, &msg->id)) {
> -                       __cbq->cb->priv = msg;
> +
> +                       if (!test_bit(0, &work->pending)) {
> +                               __cbq->cb->priv = msg;
> 
> -                       __cbq->ddata = data;
> -                       __cbq->destruct_data = destruct_data;
> +                               __cbq->ddata = data;
> +                               __cbq->destruct_data = destruct_data;
> 

Still not good enough - work->pending bit gets cleared when work has
been scheduled, but before executing payload. You still have the race.

-- 
Dmitry
